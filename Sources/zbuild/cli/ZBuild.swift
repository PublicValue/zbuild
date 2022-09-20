//
// Created by Julian Kalinowski on 14.09.22.
//

import ArgumentParser

@main
struct ZBuild: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "ZBuild",
        subcommands: [Provisioning.self, Archive.self, Test.self, ExportIpa.self, UploadIpa.self],
        defaultSubcommand: Archive.self
    )

    mutating func run() throws {
    }
}