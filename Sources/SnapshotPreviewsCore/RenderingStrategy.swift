//
//  RenderingStrategy.swift
//
//
//  Created by Noah Martin on 7/6/24.
//

import Foundation
import SwiftUI

#if canImport(UIKit)
import UIKit
public typealias ImageType = UIImage
#else
import AppKit
public typealias ImageType = NSImage
#endif

public enum MarkerShape {
    case frame(CGRect)
  #if canImport(UIKit)
    case path(UIBezierPath)
  #endif
}

public struct SnapshotResult {
  public init(
    image: Result<ImageType, Error>,
    precision: Float?,
    accessibilityEnabled: Bool?,
    colorScheme: ColorScheme?,
    appStoreSnapshot: Bool?)
  {
    self.image = image
    self.precision = precision
    self.accessibilityEnabled = accessibilityEnabled
    self.colorScheme = colorScheme
    self.appStoreSnapshot = appStoreSnapshot
  }

  public let image: Result<ImageType, Error>
  public let precision: Float?
  public let accessibilityEnabled: Bool?
  public let colorScheme: ColorScheme?
  public let appStoreSnapshot: Bool?
}

public protocol RenderingStrategy {
  @MainActor func render(
    preview: SnapshotPreviewsCore.Preview,
    completion: @escaping (SnapshotResult) -> Void)
}

private let testHandler: NSObject.Type? = NSClassFromString("EMGTestHandler") as? NSObject.Type

extension RenderingStrategy {
  static func setup() {
    testHandler?.perform(NSSelectorFromString("setup"))
  }
}

