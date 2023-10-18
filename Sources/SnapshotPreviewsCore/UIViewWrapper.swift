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
  let builder: @MainActor () -> UIViewController

  init(_ builder: @escaping @MainActor () -> UIViewController) {
    self.builder = builder
  }

  func makeUIViewController(context: Context) -> UIViewController {
    builder()
  }

  func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }
}

struct UIViewWrapper: UIViewRepresentable {

  let builder: @MainActor () -> UIView

  init(_ builder: @escaping @MainActor () -> UIView) {
    self.builder = builder
  }

  func makeUIView(context: Context) -> UIView {
    builder()
  }

  func updateUIView(_ uiView: UIView, context: Context) { }
}
