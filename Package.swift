// swift-tools-version:4.0
// https://github.com/apple/swift-package-manager/blob/master/Documentation/PackageDescriptionV4.md

import Foundation
import PackageDescription

let package = Package(
    name: "PD",
    products: [
        .library(name: "PD", targets: ["PD"]),
    ],
    dependencies: [
        .package(url: "https://github.com/eonil/swift-tree", .branch("master")),
    ],
    targets: [
        .target(
            name: "PD",
            dependencies: ["Tree"],
            path: "PD"),
        .testTarget(
            name: "PDTest",
            dependencies: ["PD", "Tree"],
            path: "PDTest"),
    ]
)
