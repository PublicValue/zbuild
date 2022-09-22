//
// Created by Julian Kalinowski on 15.09.22.
//

import Foundation
import ArgumentParser
import Files
import Factory

struct Archive: AsyncParsableCommand {

    static var configuration = CommandConfiguration(
        abstract: "Archive project to xcarchive"
    )

    @Option var scheme: String
    @OptionGroup var options: AuthenticationOptions

    @Argument var projectDir: String = "."
    @Option var archivePath: String = FileManager.default.currentDirectoryPath + "/build"

    @Option(help: "Base64 encoded signing key location") var signingKeyPath: String
    @Option(help: "Password for the signing key, if any") var signingKeyPassword: String?

    mutating func run() async throws {
        print("AuthKeyPath: " + options.authenticationKeyPath)
        print("Key ID: " + options.authenticationKeyID)
        print("Issuer ID: " + options.authenticationKeyIssuerID)

        let acapi = try? ACApi(issuerID: options.authenticationKeyIssuerID, privateKeyId: options.authenticationKeyID, privateKeyPath: options.authenticationKeyPath)
        Container.acApi.register { acapi }

        let tempDir = try Folder(path: "").createSubfolderIfNeeded(withName: "build")

        let xcbuild = XCodeBuild(workingDir: projectDir)
        let xcrun = XCRun(workingDir: projectDir)

        let bundleId = try await xcbuild.getBundleId()

        print("Found Bundle id: \(bundleId)")

        let getProfile = GetProfileInteractor()
        let profile = try await getProfile(bundleId: bundleId)

        guard let profile = profile else {
            throw ZBuildError(message: "No profile found for bundle \(bundleId)")
        }

        print("Using provisioning profile: \(profile)")

        if profile.type == .remote {
            print("Installing profile locally...")
            let installProfile = InstallProvisioningProfileInteractor()
            try await installProfile(profile: profile)
        }

        // TODO check if profile matches signing key

        let installKey = InstallSigningKeyInteractor(tempDir: tempDir)
        try await installKey(signingKeyPath: signingKeyPath, signingKeyPassword: signingKeyPassword)

        let timestamp = (Int(Date().timeIntervalSince1970))
        print("Using timestamp: \(timestamp)")
        try await xcrun.execute(arguments: ["agvtool", "new-version", "-all", "\(timestamp)"])

        let archivePath = try archivePath.toFile(defaultFileNameIfFolder: "\(scheme).xcarchive")

        print("Archiving to: \(archivePath.path)")

        try await xcbuild.execute(arguments: [
            "archive",
            "-sdk", "iphoneos",
            "-scheme", scheme,
            "-scmProvider", "system",
            "-destination", "generic/platform=iOS",
            "-configuration", "Release",
            "-allowProvisioningUpdates",
            "-archivePath", archivePath.path,
            "CODE_SIGN_STYLE=Manual",
            "CODE_SIGN_IDENTITY=iPhone Distribution",
            "PROVISIONING_PROFILE=\(profile.uuid)"
        ])

        let deleteKey = DeleteKeyChainInteractor()
        try await deleteKey()
    }
}