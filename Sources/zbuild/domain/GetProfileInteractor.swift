//
// Created by Julian Kalinowski on 15.09.22.
//

import Foundation
import AppStoreConnect_Swift_SDK
import Files
import Factory

class GetProfileInteractor {

    @Injected(Container.profileRepo) private var profileRepo

    func callAsFunction(bundleId: String, output: String? = nil) async throws -> Profile? {
        let profile = try await profileRepo.getRemoteProfile(for: bundleId)

        if let output = output {
            print("Using output: \(output)")

            do {
                let file = try output.toFile(defaultFileNameIfFolder: "\(profile?.id ?? "unknownid").mobileprovision")
                try profile?.saveToFile(outFile: file)
            } catch let error as FilesError<Any> {
                print("Error writing to file: \(error.description)")
                throw ZBuildError(message: "Error")
            }

            return profile
        } else {
            return profile
        }
    }
}