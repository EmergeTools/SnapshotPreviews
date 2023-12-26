//
//  Color.swift
//  DemoModule
//
//  Created by Noah Martin on 12/11/23.
//

import Foundation

#if canImport(UIKit)
import UIKit
public typealias PlatformColor = UIColor
#else
import AppKit

public typealias PlatformColor = NSColor

extension NSColor {
  public static var systemBackground: NSColor {
    NSColor.windowBackgroundColor
  }

  public static var label: NSColor {
    NSColor.labelColor
  }
}
#endif
