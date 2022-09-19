//
// Created by Julian Kalinowski on 19.09.22.
//

import Foundation
import Factory

extension Container {
    static let profileRepo = Factory(scope: .singleton) { ProfileRepo() as ProfileRepo }

    static let acApi = Factory<ACApi?>(scope: .singleton) { nil }

    static let localProfileDataSource = Factory(scope: .singleton) { LocalProfileDataSource() }
}

