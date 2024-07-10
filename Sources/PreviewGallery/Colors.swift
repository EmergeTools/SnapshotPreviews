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

extension PlatformColor {
  #if os(watchOS)
  static var label: UIColor {
    UIColor.white
  }
  static var secondaryLabel: UIColor {
    UIColor.gray
  }
  #endif
  #if os(tvOS) || os(watchOS)
  static var gallerySecondaryBackground: UIColor {
    UIColor.lightGray
  }

  static var galleryBackground: UIColor {
    UIColor.lightGray
  }
  #else
  static var gallerySecondaryBackground: UIColor {
    UIColor.secondarySystemGroupedBackground
  }

  static var galleryBackground: UIColor {
    UIColor.systemGroupedBackground
  }
  #endif
}

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

  static var gallerySecondaryBackground: NSColor {
    NSColor.controlBackgroundColor
  }

  static var galleryBackground: NSColor {
    NSColor.windowBackgroundColor
  }
}
#endif
