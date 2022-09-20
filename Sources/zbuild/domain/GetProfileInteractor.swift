//
// Created by Julian Kalinowski on 15.09.22.
//

import Foundation
import AppStoreConnect_Swift_SDK
import Files
import Factory

class GetProfileInteractor {

    @Injected(Container.profileRepo) private var profileRepo

    func callAsFunction(bundleId: String, output: String? = nil) async throws -> DomainProfile? {
        let profile = try await profileRepo.getProfile(for: bundleId)
        return profile
    }
}