//
// Created by Julian Kalinowski on 15.09.22.
//

import Foundation
import SwiftCommand
import SystemPackage

struct Security {

    let cmdName = "security"

    func execute(arguments: [String]) async throws {
        print("Calling \(cmdName) \(arguments)")
        let exitStatus:ExitStatus? = try Command.findInPath(withName: cmdName)?
                .addArguments(arguments)
                .wait()

        if let exitStatus = exitStatus {
            if !exitStatus.terminatedSuccessfully {
                throw ZBuildError(message: "Command failed with code: \(exitStatus.exitCode)")
            }
        }
    }

    func executeWithResult(arguments: [String]) async throws -> ChildProcess<UnspecifiedInputSource, PipeOutputDestination, UnspecifiedOutputDestination>.OutputHandle.AsyncLines {
        let output = try Command.findInPath(withName: cmdName)?
                .addArguments(arguments)
                .setStdout(.pipe)
                .spawn()
        let seq = output!.stdout.lines
        return seq
    }
}

extension Security {
    func importKey(keyChain:String, filePath: String, password: String?) async throws {
        // -T  Specify an application which may access the imported key (multiple -T options are allowed)
        var args = ["import", filePath, "-k", keyChain, "-T", "/usr/bin/codesign", "-T", "/usr/bin/security"]
        if let password = password {
            args.append("-P")
            args.append(password)
        }
        try await execute(arguments: args)
    }

    func importCert(keyChain: String, _ data: Data) async throws {
        let tempDir = try LocationDefaults.getTempDir().createSubfolderIfNeeded(at: "certs")
        let certName = UUID().uuidString + ".cer"
        let file = try tempDir.createFileIfNeeded(at: certName)
        try file.write(data)
        let args = ["import", file.path, "-k", keyChain]
        try await execute(arguments: args)
    }

    func deleteKeychain(name: String = "zbuild") async throws {
        try await execute(arguments: ["delete-keychain", name])
    }

    func createKeychain(name: String = "zbuild", password: String) async throws {
        try await execute(arguments: ["create-keychain", "-p", password, name])
    }

    func setDefaultKeychain(name: String = "zbuild") async throws {
        try await execute(arguments: ["default-keychain", "-s", name])
    }

    func unlockKeychain(name: String = "zbuild", password: String) async throws {
        try await execute(arguments: ["unlock-keychain", "-p", password, name])
    }

    func setTimeout(name: String = "zbuild", value: Int = 600) async throws {
        let keychainPath = FileManager.default.homeDirectoryForCurrentUser.path + "/Library/Keychains/\(name)-db"
        try await execute(arguments: ["set-keychain-settings", "-t", "\(value)", "-u", keychainPath])
    }


    func setPartitionList(name: String, password: String) async throws {
//        security set-key-partition-list -S apple-tool:,apple: -s -k $PASS ~/Library/Keychains/login.keychain-db
        let keychainPath = FileManager.default.homeDirectoryForCurrentUser.path + "/Library/Keychains/\(name)-db"
        try await execute(arguments: ["set-key-partition-list", "-S", "apple-tool:,apple:", "-s", "-k", password, keychainPath])
    }

    func addKeychainToAccessList(name: String = "zbuild") async throws {
        let keychainPath = FileManager.default.homeDirectoryForCurrentUser.path + "/Library/Keychains/\(name)-db"

        let existingKeychains = try await executeWithResult(arguments: ["list-keychains"])
        var chains:[String] = []
        for try await line in existingKeychains {
            let cleaned = line.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\"", with: "")
            if cleaned != keychainPath {
                chains.append(cleaned)
            }
        }

        // remove duplicate entries
        chains = Array(Set(chains))

        var args = ["list-keychains", "-d", "user", "-s"]
        args.append(contentsOf: chains)
        args.append(keychainPath)
        try await execute(arguments: args)
    }
}