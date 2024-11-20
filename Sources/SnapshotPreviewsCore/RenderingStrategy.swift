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

public protocol AccessibilityMark {
  var description: String { get }
  var hint: String? { get }
  var userInputLabels: [String]? { get }
  var accessibilityShape: MarkerShape { get }
  var activationPoint: CGPoint { get }
  var usesDefaultActivationPoint: Bool { get }
  var customActions: [String] { get }
  var accessibilityLanguage: String? { get }

}

public struct SnapshotResult {
  public init(
    image: Result<ImageType, Error>,
    precision: Float?,
    accessibilityEnabled: Bool?,
    accessibilityMarkers: [AccessibilityMark]?,
    colorScheme: ColorScheme?,
    appStoreSnapshot: Bool?)
  {
    self.image = image
    self.precision = precision
    self.accessibilityEnabled = accessibilityEnabled
    self.accessibilityMarkers = accessibilityMarkers
    self.colorScheme = colorScheme
    self.appStoreSnapshot = appStoreSnapshot
  }

  public let image: Result<ImageType, Error>
  public let precision: Float?
  public let accessibilityEnabled: Bool?
  public let accessibilityMarkers: [AccessibilityMark]?
  public let colorScheme: ColorScheme?
  public let appStoreSnapshot: Bool?
}

public protocol RenderingStrategy {
  @MainActor func render(
    preview: SnapshotPreviewsCore.Preview,
    completion: @escaping (SnapshotResult) -> Void)
  
  @MainActor func preparePreview(
    preview: SnapshotPreviewsCore.Preview
  ) async
}

private let testHandler: NSObject.Type? = NSClassFromString("EMGTestHandler") as? NSObject.Type

extension RenderingStrategy {
  static func setup() {
    testHandler?.perform(NSSelectorFromString("setup"))
  }
  
  @MainActor public func preparePreview(
    preview: SnapshotPreviewsCore.Preview
  ) async {
    if #available(iOS 18.0, *) {
      await preview.loadPreviewModifiers()
    }
  }
}

