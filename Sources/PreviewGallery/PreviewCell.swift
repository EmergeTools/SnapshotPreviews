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
        .border(Color.dynamicBackground)
        .background {
          Checkerboard()
            .foregroundStyle(Color.lightChecker)
            .background(Color.dynamicBackground)
        }
        .preferredColorScheme(nil)
        .colorScheme(try! preview.colorScheme() ?? colorScheme)
    }
  }

}

private extension Color {
  static let lightChecker = Color(#colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 0.18))
  static let slate100 = Color(#colorLiteral(red: 0.9450980392, green: 0.9607843137, blue: 0.9764705882, alpha: 1))

  static let dynamicBackground = {
    Color(UIColor { traitCollection in
      if traitCollection.userInterfaceStyle == .dark {
        return UIColor(Color.black)
      }
      return UIColor(Color.slate100)
    })
  }()
}
