//
//  PreviewCell.swift
//
//
//  Created by Noah Martin on 8/18/23.
//

import Foundation
import SwiftUI
import SnapshotPreviewsCore

struct PreviewCell: View {

  let preview: SnapshotPreviewsCore.Preview

  @Environment(\.colorScheme) var colorScheme

  var body: some View {
    VStack {
      try! preview.view()
        .padding(.vertical, 8)
        .border(Color(UIColor.separator))
        .background {
          Checkerboard()
            .foregroundStyle(Color(UIColor.label))
            .opacity(0.1)
            .background(Color(UIColor.systemBackground))
        }
        .preferredColorScheme(nil)
        .colorScheme(try! preview.colorScheme() ?? colorScheme)
    }
  }

}
