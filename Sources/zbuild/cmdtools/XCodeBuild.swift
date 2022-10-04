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

//        let xcodebuild = Command.findInPath(withName: "xcodebuild")?
//                .addArguments(arguments)
//                .setCWD(FilePath(workingDir))

        guard let xcodePath = Command.findInPath(withName: "xcodebuild") else {
            throw ZBuildError("Could not find xcodebuild in path")
        }

        let xcodebuild = Process()
        let url = xcodePath.executablePath.url
        xcodebuild.executableURL = url
        xcodebuild.currentDirectoryPath = workingDir
        xcodebuild.arguments = arguments
        let outPipe = Pipe()
        xcodebuild.standardOutput = outPipe
        let errPipe = Pipe()
        xcodebuild.standardError = errPipe

        let outputHandle = outPipe.fileHandleForReading
        outputHandle.waitForDataInBackgroundAndNotify()

        let handler: (FileHandle) -> () = { pipe in

            guard let currentOutput = String(data: pipe.availableData, encoding: .utf8) else {
                print("Error decoding data: \(pipe.availableData)")
                return
            }

            guard !currentOutput.isEmpty else {
                return
            }
//            output = output + currentOutput + "\n"

            DispatchQueue.main.async {
                print(currentOutput)
            }
        }
        outputHandle.readabilityHandler = handler

        let errHandle = errPipe.fileHandleForReading
        errHandle.waitForDataInBackgroundAndNotify()

        errHandle.readabilityHandler = handler

        try xcodebuild.run()
        xcodebuild.waitUntilExit()

        if xcodebuild.terminationStatus != 0 {
            throw ZBuildError(message: "Command failed with code: \(xcodebuild.terminationStatus))")
        }

//        let exitStatus:ExitStatus?
//        if let xcbeautify = xcbeautify, let xcodebuild = xcodebuild {
//            // pipe output through xcbeautify
//            print("Found xcbeautify, piping output...")
//            let xcodebuildProc = try xcodebuild.setStdout(.pipe).spawn()
//
//            try xcbeautify
//                    .setStdin(.pipe(from: xcodebuildProc.stdout))
//                    .wait()
//            exitStatus = try xcodebuildProc.wait()
//        } else {
//            print("Could not find xcbeautify. For more beautiful output, please install xcbeautify.")
//            exitStatus = try xcodebuild?.wait()
//        }
//
//
//        if let exitStatus = exitStatus {
//            if !exitStatus.terminatedSuccessfully {
//                throw ZBuildError(message: "Command failed with code: \(exitStatus.exitCode.map{String($0)} ?? "Unknown")")
//            }
//        }
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