//
// Created by Julian Kalinowski on 15.09.22.
//

import Foundation
import Files
import ArgumentParser

struct UploadIpa: AsyncParsableCommand {

    static var configuration = CommandConfiguration(
        abstract: "Upload exported IPA to TestFlight"
    )

    @Argument var projectDir: String = "."

    @OptionGroup var options: AuthenticationOptions
    @OptionGroup var xcoptions: XcodeOptions

    @Option(help: "The path to the ipa to upload. Can be left empty if you set scheme.") var ipaPath: String?
    @Option(help: "If you set scheme, ipaPath will be inferred using defaults from exportIpa command") var scheme: String?

    mutating func run() async throws {
        if scheme != nil && ipaPath != nil {
            throw ZBuildError("Scheme or ipaPath must be set!")
        }

        if scheme == nil && ipaPath == nil {
            throw ZBuildError("Only one of ipaPath, scheme should be set!")
        }

        let xcrun = XCRun()
        let xcbuild = XCodeBuild(workingDir: projectDir, xcbeautify: xcoptions.xcbeautify, quiet: xcoptions.quiet, configuration: xcoptions.configuration)
        let productName = try await xcbuild.getProductName()

        let ipaFile: File
        if let scheme = scheme {
            ipaFile = try Folder(path: LocationDefaults.getIpaExportDir(for: scheme)).file(named: productName + ".ipa")
        } else if let ipaPath = ipaPath {
            ipaFile = try File(path: ipaPath)
        } else {
            throw ZBuildError("Could not construct path to ipa from scheme \(scheme) or ipaPath \(ipaPath)")
        }

        try await xcrun.uploadIpa(ipaFile: ipaFile.path, apiKeyId: options.authenticationKeyID, apiIssuer: options.authenticationKeyIssuerID, apiPrivateKeyPath: options.authenticationKeyPath)
    }
}