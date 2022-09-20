//
// Created by Julian Kalinowski on 20.09.22.
//

import Foundation
import AppStoreConnect_Swift_SDK

extension MobileProvision {
    func toDomain(rawData: Data) -> DomainProfile {
        DomainProfile(
                profileContent: rawData.base64EncodedData(),
                name: self.name,
                uuid: self.uuid,
                type: .local
        )
    }
}

extension Profile {
    func toDomain() throws -> DomainProfile {
        if let uuid = attributes?.uuid, let profileContent = attributes?.profileContent?.data(using: .utf8), let name = attributes?.name {
            return DomainProfile(
                    profileContent: profileContent,
                    name: name,
                    uuid: uuid,
                    type: .remote
            )
        } else {
            throw ZBuildError("Could not use profile from AppStoreConnect: uuid or profilecontent missing")
        }
    }
}

//func saveToFile(outFile: File) throws {
//    print("Writing profile to \(outFile)")
//    let content = self.attributes?.profileContent
//    guard let content = content, let data = Data(base64Encoded: content) else {
//        throw ZBuildError(message: "Could not decode profile content from base64")
//    }
//    try outFile.write(data)
//}