// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SnapshotPreviews",
    platforms: [.iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        // Test library to import in your XCTest target.
        // This is the only library that depends on XCTest.framework
        .library(
          name: "SnapshottingTests",
          targets: ["SnapshottingTests"]),
        // Core functionality for snapshotting exported from the internal package
        .library(
          name: "SnapshotPreviewsCore",
          targets: ["SnapshotPreviewsCore"]),
    ],
    dependencies: [
      .package(name: "Snapshotting", path: "Sources/Snapshotting"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        // Snapshotting must be a dependency here so it dynamically links
        .target(name: "SnapshottingTests", dependencies: [.product(name: "Snapshotting", package: "Snapshotting")]),
        .target(name: "SnapshotPreviewsCore", dependencies: [.product(name: "SnapshottingCore", package: "Snapshotting")]),
        .testTarget(
            name: "SnapshotPreviewsTests",
            dependencies: ["SnapshotPreviewsCore"]),
    ]
)
