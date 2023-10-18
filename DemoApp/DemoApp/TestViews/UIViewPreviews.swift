//
//  UIViewPreviews.swift
//  DemoModule
//
//  Created by Noah Martin on 10/9/23.
//

import Foundation
import UIKit

#Preview {
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

#Preview(body: {
  return TestViewController() as UIViewController
})
