//
// Created by Julian Kalinowski on 14.09.22.
//

//import Foundation
import ArgumentParser
import AppStoreConnect_Swift_SDK
import Files


extension ZBuild {

    struct Archive: AsyncParsableCommand {
        static var configuration
                = CommandConfiguration(abstract: "Archive project")

        @OptionGroup var options: AuthenticationOptions

        mutating func run() async throws {
            let api = try ACApi(issuerID: options.authenticationKeyIssuerID, privateKeyId: options.authenticationKeyID, privateKeyPath: options.authenticationKeyPath)

//            do {
//                let profiles = try await api.getProvisioningProfiles()
//                for profile in profiles {
//                    print(profile)
//                }
//            } catch APIProvider.Error.requestFailure(let statusCode, let errorResponse, _) {
//                print("Request failed with statuscode: \(statusCode) and the following errors:")
//                errorResponse?.errors?.forEach({ error in
//                    print("Error code: \(error.code)")
//                    print("Error title: \(error.title)")
//                    print("Error detail: \(error.detail)")
//                })
//            } catch {
//                print("Something went wrong fetching the profiles: \(error.localizedDescription)")
//            }
        }
    }
}
