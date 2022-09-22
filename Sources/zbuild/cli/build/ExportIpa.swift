//
// Created by Julian Kalinowski on 15.09.22.
//

import Foundation
import Files
import ArgumentParser
import Factory

struct ExportIpa: AsyncParsableCommand {

    static var configuration = CommandConfiguration(
        abstract: "Export IPA from xcarchive"
    )

    @Argument var projectDir: String = "."

    @Option var archivePath: String?
    @Option var exportPath: String?
    @Option var scheme: String

    @OptionGroup var options: AuthenticationOptions

    @Option(help: "Base64 encoded signing key location") var signingKeyPath: String
    @Option(help: "Password for the signing key, if any") var signingKeyPassword: String?

    mutating func run() async throws {
        let tempDir = try LocationDefaults.getTempDir()// try Folder(path: "").createSubfolderIfNeeded(withName: "build")

        let xcodebuild = XCodeBuild(workingDir: projectDir)
        let bundleId = try await xcodebuild.getBundleId()

        let acapi = try? ACApi(issuerID: options.authenticationKeyIssuerID, privateKeyId: options.authenticationKeyID, privateKeyPath: options.authenticationKeyPath)
        Container.acApi.register { acapi }

        let getProfile = GetProfileInteractor()
        let profile = try await getProfile(bundleId: bundleId)

        let installKey = InstallSigningKeyInteractor(tempDir: tempDir)
        try await installKey(signingKeyPath: signingKeyPath, signingKeyPassword: signingKeyPassword)

        // TODO check if profile matches signing key

        var provisioningProfileName: String
        if let profile = profile {
            print("Using profile: \(profile.name) uuid:\(profile.uuid)")
            provisioningProfileName = profile.name
        } else {
            throw ZBuildError(message: "No profile found for bundle \(bundleId)")
        }

        print("Writing exportOptions.plist")
        let write = WritePlistInteractor()
        let plistFile = try tempDir.createFile(at: "exportOptions.plist")

        defer {
            do {
                try plistFile.delete()
            } catch {
            }
        }

        try write(outputFile: plistFile, options: ExportOptions(
            bundleId: bundleId,
            provisioningProfileName: provisioningProfileName
        ))

        let xcarchive = archivePath ?? LocationDefaults.getXCArchivePath(for: scheme)
        let exportPath = exportPath ?? LocationDefaults.getIpaExportDir(for: scheme)

        print("Exporting to: \(exportPath)")
        try await xcodebuild.exportIpa(
            archivePath: xcarchive,
            exportPath: exportPath,
            exportOptionsPlist: plistFile.path
        )

        let deleteKey = DeleteKeyChainInteractor()
        try await deleteKey()
    }
}