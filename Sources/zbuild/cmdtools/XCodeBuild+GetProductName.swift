//
// Created by Julian Kalinowski on 15.09.22.
//

import Foundation

extension XCodeBuild {
    func getProductName() async throws -> String {
        let result = try await executeWithResult(arguments: ["-showBuildSettings"])
        for try await line in result {
            if (line.trimmingCharacters(in: .whitespaces).starts(with: "PRODUCT_NAME")) {
                if let bundleId = line.split(separator: "=").last?.trimmingCharacters(in: .whitespaces) {
                    return bundleId
                }  else {
                    throw ZBuildError(message: "No product name found in line: \(line)")
                }
            }
        }
        throw ZBuildError(message: "No product name found!")
    }
}