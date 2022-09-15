//
// Created by Julian Kalinowski on 15.09.22.
//

import Foundation
import SwiftCommand
import SystemPackage

class XCodeBuild {

    let workingDir: String

    init(workingDir: String = "") {
        self.workingDir = workingDir
    }

    func execute(arguments: [String]) async throws {
        let exitStatus:ExitStatus? = try Command.findInPath(withName: "xcodebuild")?
                .addArguments(arguments)
                .setCWD(FilePath(workingDir))
                .wait()

        if let exitStatus = exitStatus {
            if !exitStatus.terminatedSuccessfully {
                throw ZBuildError(message: "Command failed with code: \(exitStatus.exitCode)")
            }
        }
    }

    func executeWithResult(arguments: [String]) async throws -> ChildProcess<UnspecifiedInputSource, PipeOutputDestination, UnspecifiedOutputDestination>.OutputHandle.AsyncLines {
        let output = try Command.findInPath(withName: "xcodebuild")?
                .addArguments(arguments)
                .setCWD(FilePath(workingDir))
                .setStdout(.pipe)
                .spawn()
//        if output?.status.terminatedSuccessfully == false {
//            throw ZBuildError(message: "Command failed with code: \(output?.status.exitCode)")
//        }
//        return output?.stdout

//        for try await line in output!.stdout.lines {
//            print(line)
//        }
        let seq = output!.stdout.lines
        return seq
    }
}