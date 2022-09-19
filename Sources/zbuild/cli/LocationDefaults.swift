//
// Created by Julian Kalinowski on 19.09.22.
//

import Foundation
import Files

struct LocationDefaults {

    static func getXCArchivePath(for scheme: String) -> String {
        FileManager.default.currentDirectoryPath + "/build/\(scheme).xcarchive"
    }

    static func getIpaExportDir(for scheme: String) -> String {
        FileManager.default.currentDirectoryPath + "/build/\(scheme)-ipa"
    }

    static func getTempDir() throws -> Folder {
        try Folder(path: FileManager.default.temporaryDirectory.path).createSubfolderIfNeeded(at: "zbuild")
    }
}