//
//  ContentView.swift
//  DemoApp
//
//  Created by Noah Martin on 7/3/23.
//

import SwiftUI
import DemoModule
import ETBrowser

struct ContentView: View {
  var body: some View {
    NavigationView {
      VStack {
        NavigationLink("Open Browser") {
          ETBrowser()
        }
        Image(systemName: "globe")
          .imageScale(.large)
          .foregroundStyle(.tint)
        Text("Hello, world!")
      }
      .padding()
    }
  }
}

struct ContentView_Previews: PreviewProvider {

  static var previews: some View {
    ContentView()
  }
}
