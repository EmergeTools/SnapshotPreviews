//
//  PreviewLayoutTest.swift
//  
//
//  Created by Noah Martin on 8/9/24.
//

import Foundation
import SnapshotPreviewsCore
import SnapshottingTestsObjc
import SwiftUI
import XCTest

// Test Xcode previews by forcing a layout pass of each one
open class PreviewLayoutTest: EMGPreviewBaseTest, PreviewFilters {

  open func snapshotPreviews() -> [String]?  {
    nil
  }

  open func excludedSnapshotPreviews() -> [String]? {
    nil
  }

  static private var previews: [PreviewType] = []

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

    #if canImport(UIKit) && !os(watchOS)
    let hostingVC = UIHostingController(rootView: AnyView(preview.view()))
    #if os(visionOS) || os(watchOS)
    hostingVC.view.sizeThatFits(CGSize(width: 100, height: CGFloat.greatestFiniteMagnitude))
    #else
    hostingVC.view.sizeThatFits(UIScreen.main.bounds.size)
    #endif
    #elseif canImport(AppKit)
    let hostingVC = NSHostingController(rootView: AnyView(preview.view()))
    _ = hostingVC.sizeThatFits(in: NSScreen.main!.frame.size)
    #else
    _ = ImageRenderer(content: AnyView(preview.view())).uiImage
    #endif
  }
}
