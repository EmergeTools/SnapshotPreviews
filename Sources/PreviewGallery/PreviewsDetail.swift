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
            Text(preview.displayName ?? "Preview")
              .font(.headline)
              .foregroundStyle(Color(UIColor.label))
              .padding(.leading, 8)
            PreviewCell(preview: preview)
            Divider()
          }
        }
      }
    }
    .navigationTitle(previewType.displayName)
  }

}
