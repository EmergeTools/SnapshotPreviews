//
//  AnyViewPreview.swift
//  DemoApp
//
//  Created by Noah Martin on 8/4/23.
//

import Foundation
import SwiftUI

struct AnyView_Previews: PreviewProvider {
  static var previews: some View {
    AnyView(
      Group {
        Text("Hello")
          .previewDisplayName("Hello")
        Text("World")
          .previewDisplayName("World")
      })
    .environment(\.sizeCategory, .accessibilityExtraExtraLarge)
  }
}
