//
// Created by Julian Kalinowski on 15.09.22.
//

import Foundation
import ArgumentParser
import AppStoreConnect_Swift_SDK
import Files

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

//            let dir = try! Folder(path: "")
//            for file in dir.files {
//                print(file)
//            }

        let api = try ACApi(issuerID: options.authenticationKeyIssuerID, privateKeyId: options.authenticationKeyID, privateKeyPath: options.authenticationKeyPath)


        do {
            if let bundleId = bundleId {
                let profile = try await api.getProvisioningProfile(bundleId: bundleId)

                if let output = output {
                    print("Using output: \(output)")
                    if FileManager.default.fileExists(atPath: output), let file = try? File(path: output) {
                        try profile?.saveToFile(outFile: file)
                    } else {
                        // folder is given or file does not exist
                        var folder = try? Folder(path: output)
                        let url = URL(fileURLWithPath: output)
                        let filename = url.pathComponents.last ?? "\(profile?.id ?? "unknownid").mobileprovision"
                        if folder == nil {
                            folder = try? Folder(path: url.deletingLastPathComponent().path)
                        }
                        if let folder = folder {
                            let file = try folder.createFile(at: filename)
                            try profile?.saveToFile(outFile: file)
                        }

                        throw ZBuildError(message: "Problem with output: \(output)")
                    }
                } else {
                    print(profile)
                }
            } else {
                let profiles = try await api.getProvisioningProfiles()
                for profile in profiles {
                    print(profile)
                }
            }

        } catch APIProvider.Error.requestFailure(let statusCode, let errorResponse, _) {
            print("Request failed with statuscode: \(statusCode) and the following errors:")
            errorResponse?.errors?.forEach({ error in
                print("Error code: \(error.code)")
                print("Error title: \(error.title)")
                print("Error detail: \(error.detail)")
            })
        }
        catch let error as FilesError<Any> {
            print("Error writing to file: \(error.description)")
        }
//        catch {
//            print("Something went wrong fetching the profiles: \(error.localizedDescription)")
//        }
    }
}