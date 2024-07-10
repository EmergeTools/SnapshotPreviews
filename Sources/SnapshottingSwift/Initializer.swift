//
//  File.swift
//  
//
//  Created by Noah Martin on 7/12/23.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

@objc
public class Initializer: NSObject {

  @objc
  static public let shared = Initializer()

  override init() {
    super.init()

    #if !canImport(UIKit) || os(watchOS)
    snapshots = Snapshots()
    #else
    NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] notification in
      self?.snapshots = Snapshots()
    }
    #endif
  }
  var snapshots: Snapshots?

}
