//
// Created by Julian Kalinowski on 14.09.22.
//

import Foundation
import AppStoreConnect_Swift_SDK
import Files
import Factory


class ACApi {

    let issuerID: String
    let privateKeyId: String
    let privateKey: String

    private let configuration: APIConfiguration
    private lazy var provider: APIProvider = APIProvider(configuration: configuration)

    convenience init(issuerID: String, privateKeyId: String, privateKeyPath: String) throws {
        let file = try? File(path: privateKeyPath)
        guard let file = file else {
            throw ZBuildError(message: "Could not find file \(privateKeyPath)")
        }
        try self.init(issuerID: issuerID, privateKeyId: privateKeyId, privateKey: file)
    }

    convenience init(issuerID: String, privateKeyId: String, privateKey: File) throws {
        let data: Data? = try? privateKey.read()
        let keyString = data.flatMap { String(data: $0, encoding: .utf8) }?
                .trimmingCharacters(in: .newlines)
                .replacingOccurrences(of: "\n", with: "")
                .replacingOccurrences(of: "-----BEGIN PRIVATE KEY-----", with: "")
                .replacingOccurrences(of: "-----END PRIVATE KEY-----", with: "")
        if let keyString = keyString {
            self.init(issuerID: issuerID, privateKeyId: privateKeyId, privateKey: keyString)
        } else {
            throw ZBuildError(message: "KeyFile cannot be read: \(privateKey.path)")
        }
    }

    private init(issuerID: String, privateKeyId: String, privateKey: String) {
        self.issuerID = issuerID
        self.privateKeyId = privateKeyId
        self.privateKey = privateKey
        let configuration = APIConfiguration(issuerID: issuerID, privateKeyID: privateKeyId, privateKey: privateKey)
        self.configuration = configuration
    }

    func getProvisioningProfile(bundleId: String, profileType: Profile.Attributes.ProfileType? = nil) async throws -> DomainProfile? {
        print("Getting bundle from API...")
        let request = APIEndpoint
                .v1
                .bundleIDs
                .get(parameters: .init(
                        filterIdentifier: [bundleId],
                        fieldsBundleIDs: [.identifier, .name, .seedID, .profiles], // fieldsBundleIDs required so "platform" : "UNIVERSAL" is not received, which makes library crash
                        include: [.profiles]
                ))

        let bundleIds = try await provider.request(request)

        if (bundleIds.data.isEmpty) {
            throw ZBuildError("No applications found with bundle id \(bundleId)")
        }

        // could be a useful filter but we have to specify fieldsBundleIDs and appearently we don't get relationships then
        let profileIds: [String] = bundleIds.data
                .filter { $0.attributes?.identifier == bundleId }
                .compactMap { bundleId -> [BundleID.Relationships.Profiles.Datum]? in bundleId.relationships?.profiles?.data }
                .flatMap { $0 }
                .map { $0.id }

        let profiles = bundleIds.included?.filter { included in
            if case let .profile(content) = included {
                return profileIds.contains(content.id) && isActiveProfile(attributes: content.attributes, profileType: profileType)
            } else {
                return false
            }
        }.compactMap { included -> Profile? in
            if case let .profile(content) = included {
                return content
            } else {
                return nil
            }
        }

        if let profiles = profiles, !profiles.isEmpty {
            return try profiles.first?.toDomain()
        } else {
            throw ZBuildError("No Active profiles found for bundleId: \(bundleId)")
        }
    }

    private func isActiveProfile(attributes: Profile.Attributes?, profileType: Profile.Attributes.ProfileType?) -> Bool {
        attributes?.profileState == .active && (profileType == nil || attributes?.profileType == profileType)
    }

    private func getProvisioningProfileIds() async throws -> [Profile] {
        print("Getting all profile ids...")
        let request = APIEndpoint
                .v1
                .profiles
                .get(parameters: .init(
                        fieldsProfiles: [.bundleID, .profileState],
                        fieldsCertificates: [.name],
                        fieldsBundleIDs: [.identifier]
                ))

        let profiles = try await provider.request(request).data
        return profiles
    }

    func getProvisionProfile(id: String? = nil) async throws -> DomainProfile? {
        print("Getting profile for id \(id ?? "none")")
        let request = APIEndpoint
                .v1
                .profiles
                .get(parameters: .init(
                        filterProfileState: .init([.active]),
                        filterID: id.map {[$0]}
                ))
        let profiles = try await provider.request(request).data
        return try profiles.first?.toDomain()
    }

    func getApps() async throws -> [App] {
        let request = APIEndpoint
                .v1
                .apps
                .get(parameters: .init(
                    sort: [.bundleID],
                    fieldsApps: [.appInfos, .name, .bundleID],
                    limit: 5
                ))

        let apps = try await provider.request(request).data
        return apps
    }

}