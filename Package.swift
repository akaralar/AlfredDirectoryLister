// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DirectoryLister",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(name: "AlfredJSONEncoder", path: "AlfredJSONEncoder")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "DirectoryLister",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "AlfredJSONEncoder", package: "AlfredJSONEncoder")
            ]
        ),
        .testTarget(
            name: "DirectoryListerTests",
            dependencies: ["DirectoryLister"],
            path: "Tests"
        ),
    ]
)
