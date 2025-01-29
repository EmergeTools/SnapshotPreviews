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
public final class Initializer: NSObject, Sendable {

  @objc @MainActor
  static public let shared = Initializer()

  override init() {
    super.init()

    #if !canImport(UIKit) || os(watchOS)
    Task { @MainActor [weak self] in
      guard let self else { return }
      self.snapshots = Snapshots()
    }
    #else
    NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] notification in
      Task { @MainActor [weak self] in
        guard let self else { return }
        self.snapshots = Snapshots()
      }
    }
    #endif
  }
  
  @MainActor
  var snapshots: Snapshots?

}
