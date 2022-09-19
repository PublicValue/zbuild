//
// Created by Julian Kalinowski on 19.09.22.
//

import Foundation
import Factory
import AppStoreConnect_Swift_SDK

// TODO: convert both profile types (local + remote) to a unified datatype that can be used interchangeably
class ProfileRepo {

    @Injected(Container.localProfileDataSource) private var local: LocalProfileDataSource
    @Injected(Container.acApi) private var api: ACApi?

    func getRemoteProfile(for bundleId: String) async throws -> AppStoreConnect_Swift_SDK.Profile? {
        // TODO first check local cache

        do {
            let profile = try await api?.getProvisioningProfile(bundleId: bundleId)

            // TODO save to cache
            return profile

        } catch APIProvider.Error.requestFailure(let statusCode, let errorResponse, _) {
            print("Request failed with statuscode: \(statusCode) and the following errors:")
            errorResponse?.errors?.forEach({ error in
                print("Error code: \(error.code)")
                print("Error title: \(error.title)")
                print("Error detail: \(error.detail)")
            })
            throw ZBuildError(message: "Error")
        }
    }

    func getLocalProfile(for bundleId: String) throws -> MobileProvision? {
        return try local.getLocalProfile(bundleId: bundleId)
    }

    func installLocally(_ profile: Profile) throws {
        try local.saveProfile(profile: profile)
    }
}