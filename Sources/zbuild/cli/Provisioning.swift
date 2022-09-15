//
// Created by Julian Kalinowski on 14.09.22.
//

//import Foundation
import ArgumentParser
import AppStoreConnect_Swift_SDK
import Files


extension ZBuild {

    struct Provisioning: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Provisioning tools",
            subcommands: [GetProfile.self]
        )
    }
}
