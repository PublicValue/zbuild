//
// Created by Julian Kalinowski on 15.09.22.
//

import Foundation

extension XCodeBuild {
    func getBundleId() async throws -> String {
        let result = try await executeWithResult(arguments: ["-showBuildSettings"])
        for try await line in result {
            if (line.trimmingCharacters(in: .whitespaces).starts(with: "PRODUCT_BUNDLE_IDENTIFIER")) {
                if let bundleId = line.split(separator: "=").last?.trimmingCharacters(in: .whitespaces) {
                    return bundleId
                }  else {
                    throw ZBuildError(message: "No bundle id found in line: \(line)")
                }
            }
        }
        throw ZBuildError(message: "No bundle id found!")
    }
}