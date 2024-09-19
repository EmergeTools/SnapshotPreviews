//
//  UIViewPreviews.swift
//  DemoModule
//
//  Created by Noah Martin on 10/9/23.
//

#if canImport(UIKit)
import Foundation
import UIKit

@available(iOS 17.0, *)
#Preview("View test") {
  let label = UILabel()
  label.text = "Hello world"
  return label
}

class TestViewController: UIViewController {
  let label = UILabel()

  override func viewDidLoad() {
    super.viewDidLoad()
    label.text = "Hello world"
    label.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(label)
    label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
  }
}

@available(iOS 17.0, *)
#Preview("View controller test", body: {
  return TestViewController() as UIViewController
})

#endif
