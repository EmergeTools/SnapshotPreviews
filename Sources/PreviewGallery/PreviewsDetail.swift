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
      VStack(alignment: .leading) {
        ForEach(previewType.previews) { preview in
          VStack {
            VStack {
              Text(preview.displayName ?? "Preview")
                .font(.headline)
                .foregroundStyle(Color(UIColor.label))
              PreviewCell(preview: preview)
            }
            .padding(.vertical, 8)
            Divider()
          }
        }
      }
      .padding(.top, 8)
    }
    .navigationTitle(previewType.displayName)
  }
  
}
