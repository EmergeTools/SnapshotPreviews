//
//  PreviewBaseTest+PreviewFilters.swift
//
//
//  Created by Noah Martin on 8/9/24.
//

import Foundation
import SnapshotPreviewsCore

extension PreviewFilters where Self: PreviewBaseTest {
  @MainActor
  static func matchingPreviewTypes() -> [PreviewType] {
    return FindPreviews.findPreviews(included: Self.snapshotPreviews(), excluded: Self.excludedSnapshotPreviews())
  }
}

extension DiscoveredPreview {
  static func from(previewType: PreviewType) -> DiscoveredPreview {
    return DiscoveredPreview(typeName: previewType.typeName, displayName: previewType.displayName, numberOfPreviews: previewType.previews.count)
  }
}
