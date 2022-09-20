//
// Created by Julian Kalinowski on 15.09.22.
//

import Foundation
import Factory

class InstallProvisioningProfileInteractor {

    @Injected(Container.profileRepo) private var repo: ProfileRepo

    func callAsFunction(profile: DomainProfile) async throws {
        try repo.installLocally(profile)
    }

}