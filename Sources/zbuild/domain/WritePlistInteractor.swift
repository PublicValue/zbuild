//
// Created by Julian Kalinowski on 15.09.22.
//

import Foundation
import Files

struct ExportOptions: Encodable {
    var manageAppVersionAndBuildNumber: Bool = true
    var method: String = "app-store"
    var destination: String = "export"
    var provisioningProfiles: Dictionary<String, String> = Dictionary()

    init(manageAppVersionAndBuildNumber: Bool = true,
         method: String = "app-store",
         destination: String = "export",
         bundleId: String,
         provisioningProfileName: String
    ) {
        self.manageAppVersionAndBuildNumber = manageAppVersionAndBuildNumber
        self.method = method
        self.destination = destination
        self.provisioningProfiles = [bundleId: provisioningProfileName]
    }
}

struct WritePlistInteractor {

    func callAsFunction(outputFile: File, options: ExportOptions) throws {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml

        let data = try encoder.encode(options)
        try data.write(to: URL(fileURLWithPath: outputFile.path))
    }
}