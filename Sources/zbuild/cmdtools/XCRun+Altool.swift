//
// Created by Julian Kalinowski on 16.09.22.
//

import Foundation
import Files

extension XCRun {
    func uploadIpa(ipaFile: String, apiKeyId: String, apiIssuer: String, apiPrivateKeyPath: String) async throws {
        let tempdir = try LocationDefaults.getTempDir()
        let keyDir = try tempdir.createSubfolderIfNeeded(at: "apiKeys")

        let keyFile = try keyDir.createFileIfNeeded(withName: "AuthKey_\(apiKeyId).p8")
        // copy key to expected directory
        try keyFile.write(File(path: apiPrivateKeyPath).read())

        defer {
            do {
                try keyFile.delete()
            } catch {
            }
        }

        try await execute(arguments: [
            "altool",
            "--upload-app",
            "--type", "ios",
            "--file", ipaFile,
            "--apiKey", apiKeyId,
            "--apiIssuer", apiIssuer
        ], envVariables: ["API_PRIVATE_KEYS_DIR": keyDir.path])
    }
}