//
//  EMGPreviewBaseTest+PreviewFilters.swift
//
//
//  Created by Noah Martin on 8/9/24.
//

import Foundation
import SnapshotPreviewsCore
import SnapshottingTestsObjc

extension PreviewFilters where Self: EMGPreviewBaseTest {
  @MainActor
  static func matchingPreviewTypes() -> [PreviewType] {
    let instance = self.create()
    return FindPreviews.findPreviews(included: instance.snapshotPreviews(), excluded: instance.excludedSnapshotPreviews())
  }
}

extension EMGDiscoveredPreview {
  static func from(previewType: PreviewType) -> EMGDiscoveredPreview {
    let d = EMGDiscoveredPreview()
    d.typeName = previewType.typeName
    d.displayName = previewType.displayName
    d.numberOfPreviews = NSNumber(value: previewType.previews.count)
    return d
  }
}
