//
// Created by Julian Kalinowski on 16.09.22.
//

import Foundation

extension XCodeBuild {
    func exportIpa(archivePath: String, exportPath: String, exportOptionsPlist: String) async throws {
        try await execute(arguments: [
            "-exportArchive",
            "-archivePath", archivePath,
            "-exportOptionsPlist", exportOptionsPlist,
            "-exportPath", exportPath,
            "CODE_SIGN_STYLE=Manual"
        ])
    }
}