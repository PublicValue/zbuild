//
// Created by Julian Kalinowski on 15.09.22.
//

import Foundation
import AppStoreConnect_Swift_SDK
import Files

class InstallProvisioningProfileInteractor {

    let profileDir = try? Folder(path: "~/Library/MobileDevice/Provisioning Profiles/")

    func callAsFunction(profile: Profile) async throws {
        guard let profileDir = profileDir else {
            throw ZBuildError("Provision Profile dir not found")
        }
        guard let uuid = profile.attributes?.uuid else {
            throw ZBuildError("Provision Profile dir not found")
        }
        let outputFile = try! profileDir.createFile(at: uuid + ".mobileprovision")
        try profile.saveToFile(outFile: outputFile)
    }

}