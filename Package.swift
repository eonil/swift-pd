// swift-tools-version:4.0
// https://github.com/apple/swift-package-manager/blob/master/Documentation/PackageDescriptionV4.md

import Foundation
import PackageDescription

let package = Package(
    name: "PD",
    products: [
        .library(name: "PD", targets: ["PD"]),
//        .executable(name: "SBTMBenchmark", targets: ["SBTLBenchmark"]),
    ],
    dependencies: [
        .package(url: "https://github.com/eonil/swift-sbtl", .branch("master")),
        .package(url: "https://github.com/eonil/swift-hamt", .branch("master")),
    ],
    targets: [
        .target(
            name: "PD",
            dependencies: ["SBTL", "HAMT"],
            path: "PD"),
        .testTarget(
            name: "PDTest",
            dependencies: ["PD"],
            path: "PDTest"),
    ]
)
