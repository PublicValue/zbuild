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
    @OptionGroup var xcoptions: XcodeOptions

    @Option(help: "Base64 encoded signing key location") var signingKeyPath: String
    @Option(help: "Password for the signing key, if any") var signingKeyPassword: String?

    mutating func run() async throws {
        let tempDir = try LocationDefaults.getTempDir()// try Folder(path: "").createSubfolderIfNeeded(withName: "build")

        let xcbuild = XCodeBuild(workingDir: projectDir, xcbeautify: xcoptions.xcbeautify, quiet: xcoptions.quiet)
        let bundleId = try await xcbuild.getBundleId()

        let acapi = try? ACApi(issuerID: options.authenticationKeyIssuerID, privateKeyId: options.authenticationKeyID, privateKeyPath: options.authenticationKeyPath)
        Container.acApi.register { acapi }

        let getProfile = GetAndInstallProfileInteractor()
        let profile = try await getProfile(bundleId: bundleId)

        let installKey = InstallSigningKeyInteractor(tempDir: tempDir)
        try await installKey(signingKeyPath: signingKeyPath, signingKeyPassword: signingKeyPassword)

        // TODO check if profile matches signing key

        print("Writing exportOptions.plist")
        let write = WritePlistInteractor()
        let plistFile = try tempDir.createFile(at: "exportOptions.plist")

        defer {
            do {
                try plistFile.delete()
            } catch {
            }
        }

        let exportOptions = ExportOptions(
                bundleId: bundleId,
                provisioningProfileName: profile.name
        )

        print("exportOptions: \(exportOptions)")
        try write(outputFile: plistFile, options: exportOptions)

        let xcarchive = archivePath ?? LocationDefaults.getXCArchivePath(for: scheme)
        let exportPath = exportPath ?? LocationDefaults.getIpaExportDir(for: scheme)

        print("Exporting to: \(exportPath)")
        try await xcbuild.exportIpa(
            archivePath: xcarchive,
            exportPath: exportPath,
            exportOptionsPlist: plistFile.path
        )

        let deleteKey = DeleteKeyChainInteractor()
        try await deleteKey()
    }
}