//
//  StateView.swift
//  DemoApp
//
//  Created by Noah Martin on 8/22/23.
//

import Foundation
import SwiftUI

struct StateView: View {
  @State var state = false

  var body: some View {
    VStack {
      Text("Hello")
      Text("World")
      if state {
        Text("State set in root")
      } else {
        Text("State not set in root")
      }
      SubView(state: state)
    }.onAppear {
      state = true
    }
  }
}

struct SubView: View {
  var state = false

  var body: some View {
    if state {
      Text("State set in subview")
    } else {
      Text("State not set in subview")
    }
  }
}

struct StateView_Previews: PreviewProvider {
  static var previews: some View {
    StateView()
    StateView()
  }
}
