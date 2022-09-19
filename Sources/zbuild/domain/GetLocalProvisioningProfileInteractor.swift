//
// Created by Julian Kalinowski on 15.09.22.
//

import Foundation
import Files
import Factory


class GetLocalProvisioningProfileInteractor {

    @Injected(Container.profileRepo) private var repo: ProfileRepo

    func callAsFunction(bundleId: String) throws -> MobileProvision? {
        try repo.getLocalProfile(for: bundleId)
    }
}
