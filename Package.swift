// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let enableOptimizations = true

let package = Package(
    name: "DirectoryLister",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "directory-lister", targets: ["DirectoryLister"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/akaralar/AlfredJSONEncoder", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "DirectoryLister",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "AlfredJSONEncoder", package: "AlfredJSONEncoder")
            ],
            swiftSettings: swiftSettings()
        ),
        .testTarget(
            name: "DirectoryListerTests",
            dependencies: ["DirectoryLister"],
            path: "Tests"
        )
    ]
)

func swiftSettings() -> [SwiftSetting] {
    var settings: [SwiftSetting] = [
            .unsafeFlags([
                "-Xfrontend",
                "-warn-concurrency",
                "-enable-actor-data-race-checks",
                "-enable-bare-slash-regex"
            ])
        ]
        if enableOptimizations {
            settings.append(.unsafeFlags(["-O"]))
        }

        return settings
}
