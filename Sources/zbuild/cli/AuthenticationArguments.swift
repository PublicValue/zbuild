//
// Created by Julian Kalinowski on 14.09.22.
//

//import Foundation

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Files


struct AuthenticationOptions: ParsableArguments {

    @Option
    var authenticationKeyPath: String

    @Option
    var authenticationKeyID: String

    @Option
    var authenticationKeyIssuerID: String

}
