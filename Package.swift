// swift-tools-version:5.0
// https://github.com/apple/swift-package-manager/blob/master/Documentation/PackageDescription.md
import PackageDescription

let package = Package(
    name: "PD",
    platforms: [
        .macOS(.v10_11),
    ],
    products: [
        .library(name: "PD", type: .static, targets: ["PD"]),
    ],
    dependencies: [
        .package(url: "https://github.com/eonil/swift-tree", .branch("master")),
        .package(url: "https://github.com/ra1028/DifferenceKit", .branch("master")),
    ],
    targets: [
        .target(
            name: "PD",
            dependencies: ["Tree", "DifferenceKit"],
            path: "PD"),
        .testTarget(
            name: "PDTest",
            dependencies: ["PD", "Tree"],
            path: "PDTest"),
    ]
)
