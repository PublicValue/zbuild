//
// Created by Julian Kalinowski on 15.09.22.
//

import Foundation
import AppStoreConnect_Swift_SDK
import Files

struct InstallSigningKeyInteractor {

    let tempDir: Folder

    func callAsFunction(signingKeyPath: String, signingKeyPassword: String?) async throws {
        let data = try File(path: signingKeyPath).read()
        let decoded = Data(base64Encoded: data, options: .ignoreUnknownCharacters)
        guard let decoded = decoded else {
            throw ZBuildError("Could not decode base64 encoded signing key at \(signingKeyPath)")
        }

        let signingFile = try tempDir.createFile(at: "signing.p12")
        try signingFile.write(decoded)

        print("Installing signing key...")
        let password = UUID().uuidString

        do {
            try await Security().createKeychain(name: "zbuild", password: password)
        } catch {
            print("Could not create keychain, trying to use existing...")
        }
        try await Security().setDefaultKeychain(name: "zbuild")
        try await Security().unlockKeychain(name: "zbuild", password: password)
        try await Security().importKey(filePath: signingFile.path, password: signingKeyPassword)
        try await Security().addKeychainToAccessList(name: "zbuild")
        try signingFile.delete()
    }

}