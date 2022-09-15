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
//        if let result = result {
//            print(result)
//            return "bundleid"
//        }
        throw ZBuildError(message: "No bundle id found!")
    }

//        function getProductName() {
//        set -e
//        xcodebuild -showBuildSettings | grep PRODUCT_NAME | tail -n 1 | cut -d"=" -f 2 | xargs

}