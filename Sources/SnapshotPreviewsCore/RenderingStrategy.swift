//
//  RenderingStrategy.swift
//
//
//  Created by Noah Martin on 7/6/24.
//

import Foundation

#if canImport(UIKit)
import UIKit
public typealias ImageType = UIImage
#else
import AppKit
public typealias ImageType = NSImage
#endif


public protocol RenderingStrategy {
  @MainActor func render(
    preview: SnapshotPreviewsCore.Preview,
    completion: @escaping (Result<ImageType, Error>, Float?, Bool?) -> Void)
}

