// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Snapshotting",
    platforms: [.iOS(.v16)],
    products: [
        // Core functionality for snapshotting shared between a few use cases
        .library(
          name: "SnapshottingCore",
          targets: ["SnapshottingCore"]),
        // Dynamic library that your main app will have inserted to generate previews
        .library(
          name: "Snapshotting",
          type: .dynamic,
          targets: ["Snapshotting"]),
    ],
    targets: [
        .target(name: "SnapshottingCore"),
        .target(name: "Snapshotting", dependencies: ["SnapshottingSwift"]),
        .target(name: "SnapshottingSwift", dependencies: ["SnapshottingCore"]),
    ]
)
