//
//  PreviewsDetail.swift
//
//
//  Created by Noah Martin on 8/18/23.
//

import Foundation
import SwiftUI
import SnapshotPreviewsCore

struct PreviewsDetail: View {
  
  let previewType: PreviewType
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 12) {
        ForEach(previewType.previews) { preview in
          VStack(alignment: .center) {
            Text(preview.displayName ?? "Preview")
              .font(.headline)
              .foregroundStyle(Color(PlatformColor.label))
            PreviewCell(preview: preview)
          }
          .padding(.vertical, 16)
          #if canImport(UIKit) && !os(visionOS)
          .frame(width: UIScreen.main.bounds.width)
          #endif
          .background(Color(PlatformColor.secondarySystemGroupedBackground))
        }
      }
    }
    .background(Color(PlatformColor.systemGroupedBackground))
    .navigationTitle(previewType.displayName)
  }
  
}
