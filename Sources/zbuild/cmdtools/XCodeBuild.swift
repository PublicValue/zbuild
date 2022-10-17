//
// Created by Julian Kalinowski on 15.09.22.
//

import Foundation
import SwiftCommand
import SystemPackage

class XCodeBuild {

    let workingDir: String
    let xcbeautifyEnabled: Bool
    let quiet: Bool

    init(workingDir: String = "", xcbeautify: Bool, quiet: Bool) {
        self.workingDir = workingDir
        self.xcbeautifyEnabled = xcbeautify
        self.quiet = quiet
    }

    func execute(arguments: [String]) async throws {

        guard let xcodePath = Command.findInPath(withName: "xcodebuild") else {
            throw ZBuildError("Could not find xcodebuild in path")
        }
        var args = arguments
        if quiet {
            args.append("-quiet")
        }

        let xcodebuild = Process()
        let xcbuildOutput = Pipe()
        let xcbuildError = Pipe()

        let url = xcodePath.executablePath.url
        xcodebuild.executableURL = url
        xcodebuild.currentDirectoryPath = workingDir
        xcodebuild.arguments = args
        xcodebuild.standardOutput = xcbuildOutput
        xcodebuild.standardError = xcbuildError

        let printableOutput: Pipe

        let xcbeautify = Process()
        if xcbeautifyEnabled {
            guard let xcbeautifyPath = Command.findInPath(withName: "xcbeautify") else {
                throw ZBuildError("Could not find xcbeautify in path")
            }
            let xcbeautifyOutput = Pipe()
            let xcbeautifyError = Pipe()
            xcbeautify.executableURL = xcbeautifyPath.executablePath.url
            xcbeautify.standardOutput = xcbeautifyOutput
//            xcbeautify.standardError = xcbeautifyOutput
            xcbeautify.standardInput = xcbuildOutput

            printableOutput = xcbeautifyOutput

            try xcbeautify.run()
//            xcbeautify.waitUntilExit()
        } else {
            printableOutput = xcbuildOutput
        }

        attachPrintHandler(
            xcbuildOutput: printableOutput,
            xcbuildError: xcbuildError
        )

        try xcodebuild.run()
        xcodebuild.waitUntilExit()

        if (xcbeautifyEnabled) {
            xcbeautify.waitUntilExit()
        }

        if xcodebuild.terminationStatus != 0 {
            throw ZBuildError(message: "Command failed with code: \(xcodebuild.terminationStatus))")
        }
    }

    private func attachPrintHandler(xcbuildOutput: Pipe, xcbuildError: Pipe) {
        let outputHandle = xcbuildOutput.fileHandleForReading
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
                print(currentOutput, terminator: "")
            }
        }
        outputHandle.readabilityHandler = handler

        let errHandle = xcbuildError.fileHandleForReading
        errHandle.waitForDataInBackgroundAndNotify()
        errHandle.readabilityHandler = handler
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