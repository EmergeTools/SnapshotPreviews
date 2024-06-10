//
//  PreviewGallery.swift
//
//
//  Created by Noah Martin on 7/3/23.
//

import Foundation
import SwiftUI
import SnapshotPreviewsCore

struct PreviewCellView: View {
  let preview: PreviewType
  
  var body: some View {
    VStack(alignment: .center) {
      TitleSubtitleRow(
        title: preview.displayName,
        subtitle: "\(preview.previews.count) Preview\(preview.previews.count != 1 ? "s" : "")"
      )
      .padding(EdgeInsets(top: 12, leading: 16, bottom: 6, trailing: 16))
      
      PreviewCell(preview: preview.previews[0])
    }
    .padding(.bottom, 8)
  }
}

public struct PreviewGallery: View {
  
  let data: PreviewData
  
  @MainActor
  public init(data: PreviewData? = nil) {
    self.data = data ?? .default
  }
  
  public var body: some View {
    if data.modules.count > 0 {
      List {
        ForEach(Array(data.modules).sorted(), id: \.self) { module in
          ModulePreviews(module: module, data: data)
        }
      }
      .navigationTitle("Modules")
    } else {
      Text("No previews found")
    }
  }
}
