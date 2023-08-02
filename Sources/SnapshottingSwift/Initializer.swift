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
  public func start() {
    let snapshots = Snapshots()
    snapshots.saveSnapshots {
      snapshots.window.rootViewController = CompletedViewController()
      NSLog("done generating snapshots")
    }
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

        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if let documentsDirectory = paths.first {
            label.text = "\(documentsDirectory)"
        }

        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }
}
