//
//  Colors.swift
//
//
//  Created by Noah Martin on 12/11/23.
//

import Foundation

#if canImport(UIKit)
import UIKit
typealias PlatformColor = UIColor
#else
import AppKit

typealias PlatformColor = NSColor

extension NSColor {
  static var label: NSColor {
    NSColor.labelColor
  }

  static var secondaryLabel: NSColor {
    NSColor.secondaryLabelColor
  }

  static var secondarySystemGroupedBackground: NSColor {
    NSColor.controlBackgroundColor
  }

  static var systemGroupedBackground: NSColor {
    NSColor.windowBackgroundColor
  }
}
#endif
