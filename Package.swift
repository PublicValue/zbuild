// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "zbuild",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", exact: "1.1.4"),
        .package(url: "https://github.com/AvdLee/appstoreconnect-swift-sdk.git", exact: "2.2.0"),
        .package(url: "https://github.com/JohnSundell/Files", exact: "4.2.0"),
        .package(url: "https://github.com/Zollerboy1/SwiftCommand.git", exact: "1.1.2"),
        .package(url: "https://github.com/hmlongco/Factory.git", exact: "1.2.8" )
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "zbuild",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "AppStoreConnect-Swift-SDK", package: "appstoreconnect-swift-sdk"),
                "Files",
                "SwiftCommand",
                "Factory"
            ]),
        .testTarget(
            name: "zbuildTests",
            dependencies: [
                "zbuild"
            ]),
    ]
)
