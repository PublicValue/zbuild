//
// Created by Julian Kalinowski on 19.09.22.
//

import Foundation
import Factory
import AppStoreConnect_Swift_SDK

class ProfileRepo {

    @Injected(Container.localProfileDataSource) private var local: LocalProfileDataSource
    @Injected(Container.acApi) private var api: ACApi!

    func getProfile(for bundleId: String) async throws -> DomainProfile? {
        let local = try getLocalProfile(for: bundleId)
        if let local = local {
            print("Profile for bundle \(bundleId) found locally.")
            return local
        } else {
            print("Profile for bundle \(bundleId) not found locally, fetching...")
            let remote = try await getRemoteProfile(for: bundleId)
            return remote
        }
    }

    private func getRemoteProfile(for bundleId: String) async throws -> DomainProfile? {
        do {
            let profile = try await api.getProvisioningProfile(bundleId: bundleId)
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

    private func getLocalProfile(for bundleId: String) throws -> DomainProfile? {
        // TODO check if expired or cloud managed
        return try local.getLocalProfile(bundleId: bundleId)
    }

    func installLocally(_ profile: DomainProfile) throws {
        try local.saveProfile(profile: profile)
    }
}