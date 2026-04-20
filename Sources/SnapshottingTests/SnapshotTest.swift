//
//  SnapshotTest.swift
//
//
//  Created by Noah Martin on 8/9/24.
//

import Foundation
@_implementationOnly import SnapshotPreviewsCore
import enum SwiftUI.ColorScheme
import XCTest

extension ColorScheme {
  var stringValue: String {
    switch self {
    case .light:
      return "light"
    case .dark:
      return "dark"
    @unknown default:
      return "unknown"
    }
  }
}

/// A test class for generating snapshots of Xcode previews.
///
/// This class is designed to discover SwiftUI previews, render them, and generate snapshot images for testing purposes.
/// It provides mechanisms for filtering previews and supports different rendering strategies based on the platform.
open class SnapshotTest: PreviewBaseTest, PreviewFilters {
  
  /// Returns an optional array of preview names to be included in the snapshot testing. This also supports Regex format.
  ///
  /// Override this method to specify which previews should be included in the snapshot test.
  /// - Returns: An optional array of String containing the names of previews to be included.
  open class func snapshotPreviews() -> [String]? {
    nil
  }
  
  /// Returns an optional array of preview names to be excluded from the snapshot testing. This also supports Regex format.
  ///
  /// Override this method to specify which previews should be excluded from the snapshot test.
  /// - Returns: An optional array of String containing the names of previews to be excluded.
  open class func excludedSnapshotPreviews() -> [String]? {
    nil
  }

  #if canImport(UIKit) && !os(watchOS) && !os(visionOS) && !os(tvOS)
  open class func setupA11y() -> ((UIViewController, UIWindow, PreviewLayout) -> UIView)? {
    return nil
  }
  #endif

  /// Absolute source path of the XCTest subclass, normalized to a repo-relative
  /// path and recorded in the sidecar metadata under the `test_file_path` key
  /// during CI export.
  ///
  /// The Swift runtime does not expose the source file for a class, so callers
  /// must opt in from their own `.swift` file. Override in each `SnapshotTest`
  /// subclass and return `#filePath` so the compiler captures the path at the
  /// override site:
  ///
  /// ```swift
  /// final class MySnapshotTest: SnapshotTest {
  ///   override class var testFilePath: String? { #filePath }
  /// }
  /// ```
  ///
  /// Defaults to `nil`, which causes the sidecar to emit `test_file_path: null`.
  open class var testFilePath: String? { nil }

  /// Determines the appropriate rendering strategy based on the current platform and OS version.
  ///
  /// This method selects between UIKit, AppKit, and SwiftUI rendering strategies depending on the available frameworks and OS version.
  /// - Returns: A `RenderingStrategy` object suitable for the current environment.
  #if canImport(UIKit) && !os(watchOS) && !os(visionOS) && !os(tvOS)
  private static func makeRenderingStrategy(a11y: ((UIViewController, UIWindow, PreviewLayout) -> UIView)?) -> RenderingStrategy {
    return UIKitRenderingStrategy(a11yWrapper: a11y)
  }
  #else
  private static func makeRenderingStrategy() -> RenderingStrategy {
    #if canImport(AppKit) && !targetEnvironment(macCatalyst)
      AppKitRenderingStrategy()
    #else
    if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *) {
      SwiftUIRenderingStrategy()
    } else {
      preconditionFailure("Cannot snapshot on this device/os")
    }
    #endif
  }
    #endif
  private static var renderingStrategy: RenderingStrategy? = nil
  @MainActor private static var ciExportCoordinator: SnapshotCIExportCoordinator?

  static private var previews: [SnapshotPreviewsCore.PreviewType] = []

  static private var previewCountForFileId: [String: Int] = [:]
  static private var previewDisplayNameCountByGroup: [String: [String: Int]] = [:]

  static func resolvedFileNameComponent(
    fileId: String?,
    line: Int?,
    previewDisplayName: String?,
    previewIndex: Int,
    duplicateDisplayNameCount: Int
  ) -> String {
    if let previewDisplayName, !previewDisplayName.isEmpty, duplicateDisplayNameCount <= 1 {
      return previewDisplayName
    }

    if let fileId, !fileId.isEmpty, let line {
      return "line-\(line)"
    }

    return String(previewIndex)
  }

  @MainActor
  override class func discoverPreviews() -> [DiscoveredPreview] {
    ciExportCoordinator = SnapshotCIExportCoordinator.createFromEnvironment()

    previews = FindPreviews.findPreviews(included: Self.snapshotPreviews(), excluded: Self.excludedSnapshotPreviews())
    previewCountForFileId = [:]
    previewDisplayNameCountByGroup = [:]

    for previewType in previews {
      if let fileId = previewType.fileID {
        previewCountForFileId[fileId, default: 0] += 1
      }

      let group = SnapshotCIExportCoordinator.canonicalGroup(
        fileId: previewType.fileID,
        typeDisplayName: previewType.displayName,
        typeName: previewType.typeName
      )
      for preview in previewType.previews {
        guard let previewDisplayName = preview.displayName, !previewDisplayName.isEmpty else {
          continue
        }
        previewDisplayNameCountByGroup[group, default: [:]][previewDisplayName, default: 0] += 1
      }
    }

    return previews.map { DiscoveredPreview.from(previewType: $0) }
  }

  /// Tests a specific preview by rendering it and generating a snapshot. Subclasses should NOT override this method.
  ///
  /// This method renders the specified preview using the appropriate rendering strategy,
  /// creates a snapshot image, and attaches it to the test results.
  ///
  /// - Parameter discoveredPreview: A `DiscoveredPreviewAndIndex` object representing the preview to be tested.
  @MainActor
  override func testPreview(_ discoveredPreview: DiscoveredPreviewAndIndex) {
    guard let previewType = Self.previews.first(where: { $0.typeName == discoveredPreview.preview.typeName }) else {
      XCTFail("Preview type not found")
      return
    }

    let preview = previewType.previews[discoveredPreview.index]

    // Lazily create the rendering strategy
    let strategy: RenderingStrategy
    if let existing = Self.renderingStrategy {
      strategy = existing
    } else {
      #if canImport(UIKit) && !os(watchOS) && !os(visionOS) && !os(tvOS)
      strategy = Self.makeRenderingStrategy(a11y: Self.setupA11y())
      #else
      strategy = Self.makeRenderingStrategy()
      #endif
      Self.renderingStrategy = strategy
    }

    var typeFileName = previewType.displayName
    if let fileId = previewType.fileID, let lineNumber = previewType.line {
      typeFileName = Self.previewCountForFileId[fileId]! > 1 ? "\(fileId):\(lineNumber)" : fileId
    }

    var result: SnapshotResult? = nil
    let expectation = XCTestExpectation()
    strategy.render(preview: preview) { snapshotResult in
      result = snapshotResult
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10)
    guard let result else {
      XCTFail("Did not render")
      return
    }

    let previewGroup = SnapshotCIExportCoordinator.canonicalGroup(
      fileId: previewType.fileID,
      typeDisplayName: previewType.displayName,
      typeName: previewType.typeName
    )
    let duplicateDisplayNameCount = preview.displayName.flatMap {
      Self.previewDisplayNameCountByGroup[previewGroup]?[$0]
    } ?? 0
    let fileNameComponent = Self.resolvedFileNameComponent(
      fileId: previewType.fileID,
      line: previewType.line,
      previewDisplayName: preview.displayName,
      previewIndex: discoveredPreview.index,
      duplicateDisplayNameCount: duplicateDisplayNameCount
    )
    let baseFileName = SnapshotCIExportCoordinator.sanitize(
      "\(typeFileName)_\(fileNameComponent)"
    )
    if let coordinator = Self.ciExportCoordinator {
      let colorSchemeValue = result.colorScheme?.stringValue
      let context = SnapshotContext(
        baseFileName: baseFileName,
        testName: name,
        typeName: previewType.typeName,
        typeDisplayName: previewType.displayName,
        fileId: previewType.fileID,
        line: previewType.line,
        previewDisplayName: preview.displayName,
        previewIndex: discoveredPreview.index,
        previewId: preview.previewId,
        orientation: preview.orientation.id,
        declaredDevice: preview.device?.rawValue,
        simulatorDeviceName: ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"],
        simulatorModelIdentifier: ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"],
        precision: result.precision,
        accessibilityEnabled: result.accessibilityEnabled,
        colorScheme: colorSchemeValue,
        appStoreSnapshot: result.appStoreSnapshot)
      coordinator.enqueueExport(
        result: result,
        context: context,
        testFilePath: Self.testFilePath
      )
    } else {
      do {
        let attachment = try XCTAttachment(image: result.image.get())
        attachment.name = baseFileName
        attachment.lifetime = .keepAlways
        add(attachment)
      } catch {
        XCTFail("Error \(error)")
      }
    }
  }
}
