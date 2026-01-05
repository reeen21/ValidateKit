// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ValidateKit",
    platforms: [
        .iOS(.v17),
        .tvOS(.v17),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "ValidateKit",
            targets: ["ValidateKit"]
        ),
    ],
    targets: [
        .target(
            name: "ValidateKit"
        ),
        .testTarget(
            name: "ValidateKitTests",
            dependencies: ["ValidateKit"]
        ),
    ]
)
