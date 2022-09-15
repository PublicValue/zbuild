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

    convenience init(issuerID: String, privateKeyId: String, privateKey: File) {
        let data: Data? = try? privateKey.read()
        let keyString = data.flatMap { String(data: $0, encoding: .utf8) }?
//                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: .newlines)
                .replacingOccurrences(of: "\n", with: "")
                .replacingOccurrences(of: "-----BEGIN PRIVATE KEY-----", with: "")
                .replacingOccurrences(of: "-----END PRIVATE KEY-----", with: "")
        if let keyString = keyString {
//            print("Read key: \(keyString)")
            self.init(issuerID: issuerID, privateKeyId: privateKeyId, privateKey: keyString)
        } else {
            print("KeyFile cannot be read: \(privateKey.path)")
            exit(1)
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