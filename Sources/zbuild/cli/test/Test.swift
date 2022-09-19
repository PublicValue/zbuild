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

    mutating func run() async throws {

        let xcbuild = XCodeBuild(workingDir: projectDir)
        try await xcbuild.execute(arguments: [
            "-scheme", scheme,
            "-sdk", "iphonesimulator",
            "-destination", destination,
            "test"
        ])


    }
}