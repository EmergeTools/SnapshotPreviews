//
//  File.swift
//  
//
//  Created by Noah Martin on 7/12/23.
//

import Foundation
import UIKit

@objc
public class Initializer: NSObject {

  @objc
  static public let shared = Initializer()

  let snapshots = Snapshots()

  @objc
  @MainActor public func start() {
    snapshots.writeClassNames()
  }

}

private class CompletedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "emg_finished_label"

        label.text = "\(Snapshots.resultsDir.path)"

        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }
}
