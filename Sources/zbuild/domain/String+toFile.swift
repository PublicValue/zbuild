//
// Created by Julian Kalinowski on 16.09.22.
//

import Foundation
import Files

extension String {
    func toFile(defaultFileNameIfFolder: String) throws -> File {
        if FileManager.default.fileExists(atPath: self), let file = try? File(path: self) {
            return file
        } else {
            // folder is given or file does not exist
            var folder = try? Folder(path: self)
            if let folder = folder {
                return try folder.createFileIfNeeded(at: defaultFileNameIfFolder)
            } else {
                let url = URL(fileURLWithPath: self)
                let filename = url.pathComponents.last ?? defaultFileNameIfFolder
                folder = try? Folder(path: url.deletingLastPathComponent().path)
                if let folder = folder {
                    let file = try folder.createFileIfNeeded(at: filename)
                    return file
                } else {
                    throw ZBuildError(message: "Problem with path: \(self)")
                }
            }
        }
    }
}