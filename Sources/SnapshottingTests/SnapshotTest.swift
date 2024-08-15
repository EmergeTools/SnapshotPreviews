//
//  SnapshotTest.swift
//
//
//  Created by Noah Martin on 8/9/24.
//

import Foundation
import SnapshotPreviewsCore
import SnapshottingTestsObjc
import XCTest

// Generate snapshots of Xcode previews
open class SnapshotTest: EMGPreviewBaseTest, PreviewFilters {

  open func snapshotPreviews() -> [String]?  {
    nil
  }

  open func excludedSnapshotPreviews() -> [String]? {
    nil
  }

  private static func getRenderingStrategy() -> RenderingStrategy {
    #if canImport(UIKit) && !os(watchOS) && !os(visionOS) && !os(tvOS)
      return UIKitRenderingStrategy()
    #else
    if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *) {
      SwiftUIRenderingStrategy()
    } else {
      preconditionFailure("Cannot snapshot on this device/os")
    }
    #endif
  }
  private let renderingStrategy = getRenderingStrategy()

  static private var previews: [SnapshotPreviewsCore.PreviewType] = []

  @MainActor
  open override class func discoverPreviews() -> [EMGDiscoveredPreview] {
    previews = matchingPreviewTypes()
    return previews.map { EMGDiscoveredPreview.from(previewType: $0) }
  }

  @MainActor
  open override func test(_ preview: EMGPreview) {
    let previewType = Self.previews.first { $0.typeName == preview.preview.typeName }
    guard let preview = previewType?.previews[preview.index.intValue] else {
      XCTFail("Preview not found")
      return
    }

    var result: SnapshotResult? = nil
    let expectation = XCTestExpectation()
    renderingStrategy.render(preview: preview) { snapshotResult in
      result = snapshotResult
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10)
    guard let result else {
      XCTFail("Did not render")
      return
    }
    do {
      let attachment = try XCTAttachment(image: result.image.get())
      attachment.name = preview.displayName
      attachment.lifetime = .keepAlways
      add(attachment)
    } catch {
      XCTFail("Error \(error)")
    }
  }
}
