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
        .border(colorScheme == .light ? Color.slate100 : Color.black)
        .background {
          Checkerboard()
            .foregroundStyle(Color.lightChecker)
            .background(colorScheme == .light ? Color.slate100 : Color.black)
        }
        .preferredColorScheme(nil)
        .colorScheme(try! preview.colorScheme() ?? colorScheme)
    }
  }

}

private extension Color {
  static let lightChecker = Color(uiColor: UIColor(red: 187 / 255.0, green: 187 / 255.0, blue: 187 / 255.0, alpha: 48 / 255.0))
  static let slate100 = Color(uiColor: UIColor(red: 241 / 255.0, green: 245 / 255.0, blue: 249 / 255.0, alpha: 1))
}
