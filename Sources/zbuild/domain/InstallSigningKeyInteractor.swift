//
// Created by Julian Kalinowski on 15.09.22.
//

import Foundation
import AppStoreConnect_Swift_SDK
import Files


let keychainName = "zbuild.keychain"

/**
 see https://github.com/Apple-Actions/import-codesign-certs/blob/86acf512671cb6f09237a8440571fb97925c2394/src/security.ts#L50
 */
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

        let security = Security()

        do {
            try await security.deleteKeychain(name: keychainName)
        } catch {
            print("Could not delete keychain...")
        }
        try await security.createKeychain(name: keychainName, password: password)
//        try await security.setDefaultKeychain(name: keychainName)
        try await security.unlockKeychain(name: keychainName, password: password)
        try await security.importKey(keyChain: keychainName, filePath: signingFile.path, password: signingKeyPassword)

        try await security.importCert(keyChain: keychainName, Certs.AppleWWDRCA)
        try await security.importCert(keyChain: keychainName, Certs.AppleWWDRCAG3)
        try await security.setPartitionList(name: keychainName, password: password)
        try await security.setTimeout(name: keychainName, value: 600)

        try await security.addKeychainToAccessList(name: keychainName)

        print("import done")
        try signingFile.delete()
    }

}