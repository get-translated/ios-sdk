// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GetTranslatedSDK",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "GetTranslatedSDK",
            targets: ["GetTranslatedSDK"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GetTranslatedSDK",
            dependencies: []),
        .testTarget(
            name: "GetTranslatedSDKTests",
            dependencies: ["GetTranslatedSDK"],
            exclude: ["README.md"]),
    ]
)

