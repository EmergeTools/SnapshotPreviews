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

struct EmptyIfTest: View {
  var body: some View {
    if true {
      EmptyView()
    }
    Text("Hello World")
  }
}

struct EmptyViewTest_Previews: PreviewProvider {
  static var previews: some View {
    EmptyViewTest()
    EmptyIfTest()
  }
}
