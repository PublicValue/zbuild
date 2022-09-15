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

        @Option
        var authenticationKeyPath: String

        @Option
        var authenticationKeyID: String

        @Option
        var authenticationKeyIssuerID: String

        mutating func run() async throws {
            print(authenticationKeyPath)
            print(authenticationKeyID)
            print(authenticationKeyIssuerID)

//            let dir = try! Folder(path: "")
//            for file in dir.files {
//                print(file)
//            }

            let file = try? File(path: authenticationKeyPath)
            guard let file = file else {
                throw ZBuildError(message: "Could not find file \(authenticationKeyPath)")
            }
            let api = ACApi(issuerID: authenticationKeyIssuerID, privateKeyId: authenticationKeyID, privateKey: file)

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
