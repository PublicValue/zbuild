//
// Created by Julian Kalinowski on 15.09.22.
//

import Foundation
import Files

class GetLocalProvisioningProfileInteractor {

    let profileDir = try? Folder(path: "~/Library/MobileDevice/Provisioning Profiles/")

    func callAsFunction(bundleId: String) async throws -> MobileProvision? {
        guard let profileDir = profileDir else {
            throw ZBuildError("Provision Profile dir not found")
        }

        let profiles = profileDir.files.map { file in
                    MobileProvision.read(from: file.path)
                }
            .filter { profile in profile?.bundleId == bundleId }
                .compactMap { $0 }


        if profiles.isEmpty {
            return nil
        } else if profiles.count > 1 {
            print("Found more than one matching provisioning profile for bundleId \(bundleId) in \(profileDir), using newest by creationDate...")
            let sorted = profiles.sorted(by: {p1, p2 in p1.creationDate < p2.creationDate})
            return sorted.last
        } else {
            return profiles[0]
        }

//        let outputFile = try! profileDir.createFile(at: uuid + ".mobileprovision")
//        try profile.saveToFile(outFile: outputFile)
    }
}

extension MobileProvision {
    var bundleId: String { self.entitlements.applicationIdentifier.replacingOccurrences(of: self.bundlePrefix[0] + ".", with: "") }
}