//
// Created by Julian Kalinowski on 19.09.22.
//

import Foundation
import Files
import AppStoreConnect_Swift_SDK

class LocalProfileDataSource {
    let profilePath = "~/Library/MobileDevice/Provisioning Profiles/"

    func getLocalProfile(bundleId: String) throws -> DomainProfile? {
        var profileDir = try? Folder(path: profilePath)
        if profileDir == nil {
            try FileManager.default.createDirectory(atPath: profilePath, withIntermediateDirectories: true)
            profileDir = try? Folder(path: profilePath)
        }
        guard let profileDir = profileDir else {
            throw ZBuildError("Provision Profile dir not found and could not be created: \(profilePath)")
        }

        let profiles: [(MobileProvision, File)] = profileDir.files.map { file -> (MobileProvision, File)? in
                    let profile = MobileProvision.read(from: file.path)
                    if let profile = profile {
                        return (profile, file)
                    } else {
                        return nil
                    }
                }
                .compactMap { $0 }
                .filter { (profile, file) in profile.bundleId == bundleId }


        let result = { () -> (MobileProvision, File)? in
                if profiles.isEmpty {
                return nil
            } else if profiles.count > 1 {
                print("Found more than one matching provisioning profile for bundleId \(bundleId) in \(profileDir), using newest by creationDate...")
                let sorted = profiles.sorted(by: {p1, p2 in p1.0.creationDate < p2.0.creationDate})
                return sorted.last
            } else {
                return profiles[0]
            }
        }()
        if let data = try result?.1.read() {
            return result?.0.toDomain(rawData: data)
        } else {
            throw ZBuildError("Could not read file to rawData \(result?.1) for profile")
        }
    }

    func saveProfile(profile: DomainProfile) throws {
        guard let profileDir = profileDir else {
            throw ZBuildError("Provision Profile dir not found")
        }
        let outputFile = try! profileDir.createFile(at: profile.uuid + ".mobileprovision")
        try profile.saveToFile(outFile: outputFile)
    }
}

extension MobileProvision {
    var bundleId: String { self.entitlements.applicationIdentifier.replacingOccurrences(of: self.bundlePrefix[0] + ".", with: "") }
}

//extension Profile {
//    func saveToFile(outFile: File) throws {
//        print("Writing profile to \(outFile)")
//        let content = self.attributes?.profileContent
//        guard let content = content, let data = Data(base64Encoded: content) else {
//            throw ZBuildError(message: "Could not decode profile content from base64")
//        }
//        try outFile.write(data)
//    }
//}

extension DomainProfile {
    func saveToFile(outFile: File) throws {
        print("Writing profile to \(outFile)")

//        let content = self.attributes?.profileContent
//        guard let content = content, let data = Data(base64Encoded: content) else {
//            throw ZBuildError(message: "Could not decode profile content from base64")
//        }
        guard let data = Data(base64Encoded: self.profileContent) else {
            throw ZBuildError(message: "Could not decode profile content from base64")
        }
        try outFile.write(data)
    }
}