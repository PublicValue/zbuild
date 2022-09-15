//
// Created by Julian Kalinowski on 14.09.22.
//

//import Foundation
import ArgumentParser
import AppStoreConnect_Swift_SDK
import Files


extension ZBuild {

    struct Provisioning: AsyncParsableCommand {
        static var configuration
                = CommandConfiguration(abstract: "Provisioning tools")

        @OptionGroup var options: AuthenticationOptions

        mutating func run() async throws {
            print(options.authenticationKeyPath)
            print(options.authenticationKeyID)
            print(options.authenticationKeyIssuerID)

//            let dir = try! Folder(path: "")
//            for file in dir.files {
//                print(file)
//            }

            let file = try? File(path: options.authenticationKeyPath)
            guard let file = file else {
                throw ZBuildError(message: "Could not find file \(options.authenticationKeyPath)")
            }
            let api = ACApi(issuerID: options.authenticationKeyIssuerID, privateKeyId: options.authenticationKeyID, privateKey: file)

            do {
                let profiles = try await api.getProvisioningProfiles()
                for profile in profiles {
                    print(profile)
                }
            } catch APIProvider.Error.requestFailure(let statusCode, let errorResponse, _) {
                print("Request failed with statuscode: \(statusCode) and the following errors:")
                errorResponse?.errors?.forEach({ error in
                    print("Error code: \(error.code)")
                    print("Error title: \(error.title)")
                    print("Error detail: \(error.detail)")
                })
            } catch {
                print("Something went wrong fetching the profiles: \(error.localizedDescription)")
            }
        }
    }
}
