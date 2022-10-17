//
// Created by Julian Kalinowski on 17.10.22.
//

import Foundation
import ArgumentParser

struct XcodeOptions : ParsableArguments {
    @Flag(help: "Enable xcodebeautify")
    var xcbeautify: Bool = false

    @Flag(help: "Enable xcode -quiet flag")
    var quiet: Bool = false
}