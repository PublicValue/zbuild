//
// Created by Julian Kalinowski on 15.09.22.
//

import Foundation
import Files
import AppStoreConnect_Swift_SDK

extension Profile {
    func saveToFile(outFile: File) throws {
        print("Writing profile to \(outFile)")
        let content = self.attributes?.profileContent
        guard let content = content, let data = Data(base64Encoded: content) else {
            throw ZBuildError(message: "Could not decode profile content from base64")
        }
        try outFile.write(data)
    }
}

extension String {

    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }

}