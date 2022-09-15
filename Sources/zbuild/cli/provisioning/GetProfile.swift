//
// Created by Julian Kalinowski on 15.09.22.
//

import Foundation
import ArgumentParser


struct GetProfile: AsyncParsableCommand {

    static var configuration = CommandConfiguration(
        abstract: "Get a specific provisioning profile"
    )

    @OptionGroup var options: AuthenticationOptions

//    @Option var uuid: String?
//    @Option var id: String?
    @Option var bundleId: String?

    @Option var output: String?

    mutating func run() async throws {
        print(options.authenticationKeyPath)
        print(options.authenticationKeyID)
        print(options.authenticationKeyIssuerID)

//        if (uuid != nil && id != nil) {
//            throw ZBuildError(message: "Only one of the following options can be used: uuid, id")
//        }

        let getProfile = GetProfileInteractor()
        try await getProfile(
            authenticationKeyIssuerID: options.authenticationKeyIssuerID,
            authenticationKeyID: options.authenticationKeyID,
            authenticationKeyPath: options.authenticationKeyPath,
            bundleId: bundleId,
            output: output
        )
    }
}