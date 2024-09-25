//
//  FontSizeTest.swift
//  DemoApp
//
//  Created by Noah Martin on 9/25/24.
//

import SwiftUI

struct MyView: View {
  var body: some View {
    Text("This is a test")
  }
}

struct MyView_Regular_Previews: PreviewProvider {
    static var previews: some View {
      MyView()
        .previewLayout(.sizeThatFits)
    }
  }

  struct MyView_Large_Previews: PreviewProvider {
    static var previews: some View {
      MyView()
        .previewLayout(.sizeThatFits)
        .dynamicTypeSize(.xxxLarge)
    }
  }
