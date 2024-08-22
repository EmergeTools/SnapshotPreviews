//
//  DiscoveredPreview+PreviewType.swift
//
//
//  Created by Noah Martin on 8/9/24.
//

import Foundation
@_implementationOnly import SnapshotPreviewsCore

extension DiscoveredPreview {
  static func from(previewType: PreviewType) -> DiscoveredPreview {
    return DiscoveredPreview(typeName: previewType.typeName, displayName: previewType.displayName, numberOfPreviews: previewType.previews.count)
  }
}
