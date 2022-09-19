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

                    let file = try output.toFile(defaultFileNameIfFolder: "\(profile?.id ?? "unknownid").mobileprovision")
                    try profile?.saveToFile(outFile: file)

                    return profile
                } else {
                    return profile
                }
            } else {
                throw ZBuildError(message: "Bundle id not valid: \(bundleId)")
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