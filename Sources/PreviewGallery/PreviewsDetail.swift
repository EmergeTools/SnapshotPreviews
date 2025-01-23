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
  
  let previewGrouping: PreviewGrouping
  @State private var searchText = ""

  var previews: [SnapshotPreviewsCore.Preview] {
    previewGrouping.previews.flatMap { $0.previews(requiringFullscreen: false) }.filterWithText(searchText, { $0.displayName ?? "" })
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 12) {
        ForEach(previews) { preview in
          VStack(alignment: .center) {
            Text(preview.displayName ?? "Preview")
              .font(.headline)
              .foregroundStyle(Color(PlatformColor.label))
            PreviewCell(preview: preview)
          }
          .padding(.vertical, 16)
          #if canImport(UIKit) && !os(visionOS) && !os(watchOS)
          .frame(width: UIScreen.main.bounds.width)
          #endif
          #if !os(watchOS)
          .background(Color(PlatformColor.gallerySecondaryBackground))
          #endif
        }
      }
    }
    #if !os(watchOS)
    .background(Color(PlatformColor.galleryBackground))
    #endif
    .navigationTitle(previewGrouping.displayName)
    .searchable(text: $searchText)
  }
  
}
