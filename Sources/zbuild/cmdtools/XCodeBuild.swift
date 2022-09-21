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
        let xcbeautify = Command.findInPath(withName: "xcbeautify")

        let xcodebuild = Command.findInPath(withName: "xcodebuild")?
                .addArguments(arguments)
                .setCWD(FilePath(workingDir))

        let exitStatus:ExitStatus?
        if let xcbeautify = xcbeautify, let xcodebuild = xcodebuild, false {
            // pipe output through xcbeautify
            print("Found xcbeautify, piping output...")
            let xcodebuildProc = try xcodebuild.setStdout(.pipe).spawn()

            try xcbeautify
                    .setStdin(.pipe(from: xcodebuildProc.stdout))
                    .wait()
            exitStatus = try xcodebuildProc.wait()
        } else {
            print("Could not find xcbeautify. For more beautiful output, please install xcbeautify.")
            exitStatus = try xcodebuild?.wait()
        }


        if let exitStatus = exitStatus {
            if !exitStatus.terminatedSuccessfully {
                throw ZBuildError(message: "Command failed with code: \(exitStatus.exitCode.map{String($0)} ?? "Unknown")")
            }
        }
    }

    func executeWithResult(arguments: [String]) async throws -> ChildProcess<UnspecifiedInputSource, PipeOutputDestination, UnspecifiedOutputDestination>.OutputHandle.AsyncLines {
        let output = try Command.findInPath(withName: "xcodebuild")?
                .addArguments(arguments)
                .setCWD(FilePath(workingDir))
                .setStdout(.pipe)
                .spawn()
        let seq = output!.stdout.lines
        return seq
    }
}