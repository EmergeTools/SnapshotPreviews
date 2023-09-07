//
//  ExpandingView.swift
//  DemoApp
//
//  Created by Noah Martin on 8/2/23.
//

import Foundation
import SwiftUI

struct ExpandingView: View {
  var body: some View {
    List {
      ForEach(1..<20) { i in
        Section("Section \(i)") {
          VStack {
            Text("Subtitle").font(.title3)
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce interdum, tortor id dapibus elementum, nibh libero pretium ligula, eu bibendum nulla sapien sit amet eros. Etiam lobortis ornare nibh, ut sagittis massa egestas sed. Donec ullamcorper consequat neque, vestibulum fringilla ipsum bibendum eget. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Nullam ligula nibh, scelerisque sit amet laoreet at, eleifend vel elit. Suspendisse et tellus justo. Fusce lobortis semper ipsum. Etiam sit amet ultrices velit. Aliquam iaculis faucibus maximus. Proin vel magna orci. Vestibulum auctor vel velit eu iaculis. Quisque est purus, facilisis id ligula vel, semper dictum nibh. Curabitur gravida, est et placerat iaculis, sapien sapien accumsan lacus, a congue libero quam quis sem.")
          }
        }
      }
    }
  }
}

struct ExpandingView_Previews: PreviewProvider {
  static var previews: some View {
    ExpandingView()
    ExpandingView().emergeExpansion(false)
  }
}
