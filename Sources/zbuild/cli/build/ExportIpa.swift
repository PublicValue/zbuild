//
// Created by Julian Kalinowski on 15.09.22.
//

import Foundation
import Files
import ArgumentParser

struct ExportIpa: AsyncParsableCommand {

    static var configuration = CommandConfiguration(
        abstract: "Export IPA from xcarchive"
    )

    @Argument var projectDir: String = "."

    @Option var archivePath: String?
    @Option var exportPath: String?
    @Option var scheme: String

    mutating func run() async throws {
        // TODO use real tempdir with LocationDefaults.getTempDir
        let tempDir = try Folder(path: "").createSubfolderIfNeeded(withName: "build")

        let xcodebuild = XCodeBuild(workingDir: projectDir)
        let bundleId = try await xcodebuild.getBundleId()

        // Get Provisioning Profile from Local
        let getLocalProfile = GetLocalProvisioningProfileInteractor()
        let profile = try await getLocalProfile(bundleId: bundleId)

        var provisioningProfileName: String
        if let profile = profile {
            print("Using profile: \(profile.name) uuid:\(profile.uuid)")
            provisioningProfileName = profile.name
        } else {
            // TODO download from apple again
            throw ZBuildError("Profile for \(bundleId) not found in local Provisioning Profiles. Downloading not implemented in ExportIPA.")
        }

        print("Writing exportOptions.plist")
        let write = WritePlistInteractor()
        let plistFile = try tempDir.createFile(at: "exportOptions.plist")
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
    }
}