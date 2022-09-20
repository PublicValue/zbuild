//
// Created by Julian Kalinowski on 20.09.22.
//

import Foundation

enum ProfileType {
    case local
    case remote
}

struct DomainProfile {
    // Base64-encoded data
    let profileContent: Data

    let name: String
    let uuid: String

    let type: ProfileType
}