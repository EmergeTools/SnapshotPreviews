//
//  ContentView.swift
//  DemoApp
//
//  Created by Noah Martin on 7/3/23.
//

import SwiftUI
import DemoModule

struct ContentView: View {
  var body: some View {
    NavigationView {
      VStack {
        Image(systemName: "globe")
          .imageScale(.large)
          .foregroundStyle(.tint)
        Text("Hello, world!")
      }
      .padding()
    }
  }
}

struct LazyView<Content: View>: View {
  private let build: () -> Content
  init(_ build: @autoclosure @escaping () -> Content) {
    self.build = build
  }
  var body: Content {
    build()
  }
}

struct ContentView_Previews: PreviewProvider {

  static var previews: some View {
    ContentView()
  }
}
