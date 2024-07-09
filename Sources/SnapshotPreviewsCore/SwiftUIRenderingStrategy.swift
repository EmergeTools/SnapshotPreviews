//
//  SwiftUIRenderingStrategy.swift
//  
//
//  Created by Noah Martin on 7/5/24.
//

import Foundation
import SwiftUI

enum SwiftUIRenderingError: Error {
  case renderingError
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
public class SwiftUIRenderingStrategy: RenderingStrategy {

  public init() { }

  @MainActor public func render(
    preview: SnapshotPreviewsCore.Preview,
    completion: @escaping (Result<ImageType, any Error>, Float?, Bool?) -> Void)
  {
    let wrappedView = EmergeModifierView(wrapped: preview.view())
    let renderer = ImageRenderer(content: wrappedView)
    #if canImport(UIKit)
    let image = renderer.uiImage
    #else
    let image = renderer.nsImage
    #endif
    if let image {
      completion(.success(image), wrappedView.precision, wrappedView.accessibilityEnabled)
    } else {
      completion(.failure(SwiftUIRenderingError.renderingError), wrappedView.precision, wrappedView.accessibilityEnabled)
    }
  }
}
