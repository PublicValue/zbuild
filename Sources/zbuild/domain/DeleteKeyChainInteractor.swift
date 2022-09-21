//
// Created by Julian Kalinowski on 15.09.22.
//

import Foundation
import AppStoreConnect_Swift_SDK
import Files

struct DeleteKeyChainInteractor {

    func callAsFunction() async throws {
        let security = Security()
        try await security.deleteKeychain(name: keychainName)
    }

}