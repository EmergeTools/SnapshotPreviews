// swift-tools-version: 5.7.1
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
        // Dynamic library that your main app will have inserted to generate previews
        .library(
          name: "Snapshotting",
          type: .dynamic,
          targets: ["Snapshotting"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        // Target that provides the XCTest
        .target(name: "SnapshottingTests"),
        // Core functionality
        .target(name: "SnapshotPreviewsCore"),
        // Inserted dylib
        .target(name: "Snapshotting", dependencies: ["SnapshottingSwift"]),
        // Swift code in the inserted dylib
        .target(name: "SnapshottingSwift", dependencies: ["SnapshotPreviewsCore"]),
        .testTarget(
            name: "SnapshotPreviewsTests",
            dependencies: ["SnapshotPreviewsCore"]),
    ]
)
