//
//  File.swift
//  
//
//  Created by Noah Martin on 7/5/24.
//

import Foundation
import SwiftUI
import SnapshotPreviewsCore

enum SwiftUIRenderingError: Error {
  case renderingError
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
class SwiftUIRenderingStrategy: RenderingStrategy {
  func render(preview: SnapshotPreviewsCore.Preview, completion: @escaping (Result<UIImage, any Error>) -> Void) {
    let renderer = ImageRenderer(content: AnyView(preview.view()))
    if let image = renderer.uiImage {
      completion(.success(image))
    } else {
      completion(.failure(SwiftUIRenderingError.renderingError))
    }
  }
}
