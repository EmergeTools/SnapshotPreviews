//
//  TextView.swift
//  DemoApp
//
//  Created by Noah Martin on 9/1/23.
//

import Foundation
import SwiftUI

struct TextView: UIViewRepresentable {
  func makeUIView(context: Context) -> UITextView {
    let view = UITextView()
    view.text = "Some text"
    return view
  }

  func updateUIView(_ uiView: UITextView, context: Context) { }
}

struct TextView_Previews: PreviewProvider {
  static var previews: some View {
    TextView()
  }
}
