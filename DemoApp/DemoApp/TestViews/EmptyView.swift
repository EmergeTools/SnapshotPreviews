//
//  EmptyView.swift
//  DemoApp
//
//  Created by Noah Martin on 8/22/23.
//

import Foundation
import SwiftUI

struct EmptyViewTest: View {
  var body: some View {
    let test = true
    if test {
      EmptyView()
    } else {
      Text("Hello")
    }
    Text("World")
  }
}

struct EmptyViewTest_Previews: PreviewProvider {
  static var previews: some View {
    Text("Hi").multiplyingModifier()
  }
}


struct MultipliyinModifier: ViewModifier {

    func body(content: Content) -> some View {
      Group {
        content
        content.dynamicTypeSize(.xLarge)
      }
    }
}

extension View {
    func multiplyingModifier() -> some View {
        self.modifier(MultipliyinModifier())
    }
}
