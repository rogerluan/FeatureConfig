// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FeatureConfig",
    platforms: [
        .macOS(.v11),
        .iOS(.v14),
    ],
    products: [
        .library(name: "FeatureConfig", targets: ["FeatureConfig"]),
    ],
    dependencies: [
        .package(name: "JSEN", url: "https://github.com/rogerluan/JSEN", .upToNextMajor(from: "1.0.0")),
    ],
    targets: [
        .target(name: "FeatureConfig", dependencies: ["JSEN"], path: "Sources"),
        .testTarget(name: "FeatureConfigTests", dependencies: ["FeatureConfig"], path: "Tests"),
    ]
)
