//
// Created by Julian Kalinowski on 15.09.22.
//

import Foundation
import ArgumentParser
import Factory

struct GetProfile: AsyncParsableCommand {

    static var configuration = CommandConfiguration(
        abstract: "Get a specific provisioning profile"
    )

    @OptionGroup var options: AuthenticationOptions

    @Option var bundleId: String

    @Option var output: String?

    mutating func run() async throws {
        print(options.authenticationKeyPath)
        print(options.authenticationKeyID)
        print(options.authenticationKeyIssuerID)

        let acapi = try? ACApi(issuerID: options.authenticationKeyIssuerID, privateKeyId: options.authenticationKeyID, privateKeyPath: options.authenticationKeyPath)
        Container.acApi.register { acapi }

        let getProfile = GetProfileInteractor()
        try await getProfile(
            bundleId: bundleId,
            output: output
        )
    }
}