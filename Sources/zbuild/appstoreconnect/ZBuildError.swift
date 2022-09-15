//
// Created by Julian Kalinowski on 14.09.22.
//

import Foundation
struct ZBuildError: Error {
    let message: String

    init(_ message: String) {
        self.message = message
    }

    init(message: String) {
        self.message = message
    }
}