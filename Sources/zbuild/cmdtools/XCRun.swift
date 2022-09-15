//
// Created by Julian Kalinowski on 15.09.22.
//

import Foundation
import SwiftCommand
import SystemPackage

struct XCRun {
    let workingDir: String

    init(workingDir: String = "") {
        self.workingDir = workingDir
    }

    func execute(arguments: [String]) async throws {
        let exitStatus:ExitStatus? = try Command.findInPath(withName: "xcrun")?
                .addArguments(arguments)
                .setCWD(FilePath(workingDir))
                .wait()

        if let exitStatus = exitStatus {
            if !exitStatus.terminatedSuccessfully {
                throw ZBuildError(message: "Command failed with code: \(exitStatus.exitCode)")
            }
        }
    }
}

