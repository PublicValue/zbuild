//
// Created by Julian Kalinowski on 15.09.22.
//

import Foundation
import ArgumentParser

struct Test: AsyncParsableCommand {

    static var configuration = CommandConfiguration(
        abstract: "Run Xcode Tests"
    )

    @Option var scheme: String
    @Argument var projectDir: String = "."
    @Option var destination: String = "platform=iOS Simulator,name=iPhone 13,OS=15.5"

    @OptionGroup var xcoptions: XcodeOptions

    mutating func run() async throws {

        let xcbuild = XCodeBuild(workingDir: projectDir, xcbeautify: xcoptions.xcbeautify, quiet: xcoptions.quiet)
        try await xcbuild.execute(arguments: [
            "-scheme", scheme,
            "-sdk", "iphonesimulator",
            "-destination", destination,
            "test"
        ])


    }
}