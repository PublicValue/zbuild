//
// Created by Julian Kalinowski on 15.09.22.
//

import Foundation
import AppStoreConnect_Swift_SDK
import Files

class GetProfileInteractor {
    func callAsFunction(options: AuthenticationOptions, bundleId: String?, output: String? = nil) async throws -> Profile? {
        return try await callAsFunction(
                authenticationKeyIssuerID: options.authenticationKeyIssuerID,
                authenticationKeyID: options.authenticationKeyID,
                authenticationKeyPath: options.authenticationKeyPath,
                bundleId: bundleId, output: output)
    }

    func callAsFunction(authenticationKeyIssuerID: String, authenticationKeyID: String, authenticationKeyPath: String, bundleId: String?, output: String? = nil) async throws -> Profile? {
        let api = try ACApi(issuerID: authenticationKeyIssuerID, privateKeyId: authenticationKeyID, privateKeyPath: authenticationKeyPath)

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
                    return profile
                } else {
                    print(profile)
                    return profile
                }
            } else {
                throw ZBuildError(message: "Bundle id not valid: \(bundleId)")
//                let profiles = try await api.getProvisioningProfiles()
//                for profile in profiles {
//                    print(profile)
//                }
            }

        } catch APIProvider.Error.requestFailure(let statusCode, let errorResponse, _) {
            print("Request failed with statuscode: \(statusCode) and the following errors:")
            errorResponse?.errors?.forEach({ error in
                print("Error code: \(error.code)")
                print("Error title: \(error.title)")
                print("Error detail: \(error.detail)")
            })
            throw ZBuildError(message: "Error")
        }
        catch let error as FilesError<Any> {
            print("Error writing to file: \(error.description)")
            throw ZBuildError(message: "Error")
        }
    }
}