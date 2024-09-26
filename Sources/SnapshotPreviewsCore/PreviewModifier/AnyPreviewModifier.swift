//
//  AnyPreviewModifier.swift
//  SnapshotPreviews
//
//  Created by Itay Brenner on 26/9/24.
//

import SwiftUI

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, *)
struct AnyPreviewModifier: PreviewModifier {
  
  private let _body: (PreviewModifier.Content) -> AnyView

  init<M: PreviewModifier>(_ modifier: M) {
    let type = type(of: modifier)
    let hash = String(describing: type)

    _body = { content in
      let cachedContext = PreviewModifierContextCache.contextCache[hash]
      guard let typedContext = cachedContext as? M.Context else {
        fatalError("Context type mismatch, expected: \(String(describing: M.Context.self)), got: \(String(describing: cachedContext.self))")
      }
      return AnyView(modifier.body(content: content, context: typedContext))
    }
  }

  func body(content: PreviewModifier.Content, context: Void) -> AnyView {
    return _body(content)
  }
}
