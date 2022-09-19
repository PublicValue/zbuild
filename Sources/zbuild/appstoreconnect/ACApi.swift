//
// Created by Julian Kalinowski on 14.09.22.
//

import Foundation
import AppStoreConnect_Swift_SDK
import Files

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

    func getProvisioningProfiles() async throws -> [Profile] {
        let request = APIEndpoint
                .v1
                .profiles
                .get()

        let profiles = try await provider.request(request).data
        return profiles
    }

    func getProvisioningProfile(bundleId: String) async throws -> Profile? {
        let profiles = try await getProvisioningProfileIds()

        print("Getting bundle IDs for profiles...")
        var found: Profile?
        let bundleIdToProfile = try await profiles.asyncMap { profile -> (BundleID?, Profile) in
            if (found == nil) {
                let request = APIEndpoint
                        .v1
                        .profiles.id(profile.id)
                        .bundleID
                        .get(fieldsBundleIDs: [.identifier, .name])

                let bundleIdDto = try await provider.request(request).data
                print("found bundle id: \(bundleIdDto.attributes?.identifier) for profile: \(profile.id)")
                if (bundleIdDto.attributes?.identifier == bundleId) {
                    found = profile
                }
                return (bundleIdDto, profile)
            }
            return (nil, profile)
        }

//        let relevantProfile = bundleIdToProfile.filter { (id, profile) in id.attributes?.identifier == bundleId }.first?.1

        print("Found profile for bundle id \(bundleId): \(found)")
        if let relevantProfile = found {
            return try await getProvisionProfile(id: relevantProfile.id)
        } else {
            return nil
        }
    }

    func getProvisioningProfileIds() async throws -> [Profile] {
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

    func getProvisionProfile(id: String? = nil) async throws -> Profile? {
        print("Getting profile for id \(id ?? "none")")
        let request = APIEndpoint
                .v1
                .profiles
                .get(parameters: .init(
                        filterProfileState: .init([.active]),
                        filterID: id.map {[$0]}
                ))
        let profiles = try await provider.request(request).data
        return profiles.first
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