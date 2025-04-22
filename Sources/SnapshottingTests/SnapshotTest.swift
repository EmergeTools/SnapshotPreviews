//
//  SnapshotTest.swift
//
//
//  Created by Noah Martin on 8/9/24.
//

import Foundation
@_implementationOnly import SnapshotPreviewsCore
import XCTest
import XCTest

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

  /// Determines the appropriate rendering strategy based on the current platform and OS version.
  ///
  /// This method selects between UIKit, AppKit, and SwiftUI rendering strategies depending on the available frameworks and OS version.
  /// - Returns: A `RenderingStrategy` object suitable for the current environment.
  private static func getRenderingStrategy() -> RenderingStrategy {
    #if canImport(UIKit) && !os(watchOS) && !os(visionOS) && !os(tvOS)
      return UIKitRenderingStrategy()
    #elseif canImport(AppKit) && !targetEnvironment(macCatalyst)
      AppKitRenderingStrategy()
    #else
    if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *) {
      SwiftUIRenderingStrategy()
    } else {
      preconditionFailure("Cannot snapshot on this device/os")
    }
    #endif
  }
  private static let renderingStrategy = getRenderingStrategy()

  static private var previews: [SnapshotPreviewsCore.PreviewType] = []
  
  static private var previewCountForFileId: [String: Int] = [:]

  /// Discovers all relevant previews based on inclusion and exclusion filters. Subclasses should NOT override this method.
  ///
  /// This method uses `FindPreviews` to locate all previews, applying any specified filters.
  /// - Returns: An array of `DiscoveredPreview` objects representing the found previews.
  @MainActor
  override class func discoverPreviews() -> [DiscoveredPreview] {
    previews = FindPreviews.findPreviews(included: Self.snapshotPreviews(), excluded: Self.excludedSnapshotPreviews())
    
    for preview in previews {
        guard let fileId = preview.fileID else { continue }
        previewCountForFileId[fileId, default: 0] += 1
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
    let previewType = Self.previews.first { $0.typeName == discoveredPreview.preview.typeName }
    guard let previewType = previewType else {
      XCTFail("Preview type not found")
      return
    }

    let preview = previewType.previews[discoveredPreview.index]
    var result: SnapshotResult? = nil
    let expectation = XCTestExpectation()
    Self.renderingStrategy.render(preview: preview) { snapshotResult in
      result = snapshotResult
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10)
    guard let result else {
      XCTFail("Did not render")
      return
    }

    var typeFileName = previewType.displayName
    if let fileId = previewType.fileID, let lineNumber = previewType.line {
      typeFileName = Self.previewCountForFileId[fileId]! > 1 ? "\(fileId):\(lineNumber)" : fileId
    }
    do {
      let attachment = try XCTAttachment(image: result.image.get())
      attachment.name = "\(typeFileName)_\(preview.displayName ?? String(discoveredPreview.index))"
      attachment.lifetime = .keepAlways
      add(attachment)
    } catch {
      XCTFail("Error \(error)")
    }
  }
}
