//
// Created by Julian Kalinowski on 14.09.22.
//

//import Foundation
import ArgumentParser

@main
struct ZBuild: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "ZBuild",
        subcommands: [Provisioning.self, Archive.self],
        defaultSubcommand: Archive.self
    )

//    @Flag(help: "Include a counter with each repetition.")
//    var includeCounter = false
//
//    @Option(help: "The number of times to repeat 'phrase'.")
//    var count: Int?
//
//    @Argument(help: "The phrase to repeat.")
//    var phrase: String

//    @Option
//    var authenticationKeyPath: String
//
//    @Option
//    var authenticationKeyID: String
//
//    @Option
//    var authenticationKeyIssuerID: String

    mutating func run() throws {
//        print(authenticationKeyPath)
//        let repeatCount = count ?? 2
//        for _ in 0..<repeatCount {
//            print(phrase)
//        }
    }
}