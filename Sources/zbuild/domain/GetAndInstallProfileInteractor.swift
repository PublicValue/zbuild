//
// Created by Julian Kalinowski on 15.09.22.
//

import Foundation
import AppStoreConnect_Swift_SDK
import Files
import Factory

class GetAndInstallProfileInteractor {

    let getProfile = GetProfileInteractor()
    let installProfile = InstallProvisioningProfileInteractor()

    func callAsFunction(bundleId: String, output: String? = nil) async throws -> DomainProfile {
        let profile = try await getProfile(bundleId: bundleId)

        guard let profile = profile else {
            throw ZBuildError(message: "No profile found for bundle \(bundleId)")
        }

        print("Using provisioning profile: \(profile)")

        if profile.type == .remote {
            print("Installing profile locally...")
            try await installProfile(profile: profile)
        }

        return profile
    }
}