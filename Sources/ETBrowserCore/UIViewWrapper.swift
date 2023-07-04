//
//  File.swift
//
//
//  Created by Noah Martin on 7/3/23.
//

import Foundation
import UIKit
import SwiftUI

struct UIViewControllerWrapper: UIViewControllerRepresentable {
  let builder: () -> UIViewController

  init(_ builder: @escaping () -> UIViewController) {
    self.builder = builder
  }

  func makeUIViewController(context: Context) -> UIViewController {
    builder()
  }

  func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }
}

struct UIViewWrapper: UIViewRepresentable {

  let builder: () -> UIView

  init(_ builder: @escaping () -> UIView) {
    self.builder = builder
  }

  func makeUIView(context: Context) -> UIView {
    builder()
  }

  func updateUIView(_ uiView: UIView, context: Context) { }
}
