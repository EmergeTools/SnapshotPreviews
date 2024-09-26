//
//  View+PreviewModifier.swift
//  SnapshotPreviews
//
//  Created by Itay Brenner on 25/9/24.
//

import SwiftUI
import PreviewsSupport

extension View {
  @available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, *)
  func applyPreviewModifiers(_ modifiers: [any PreviewModifier]) -> some View {
    var currentView: AnyView = AnyView(self)
    for modifier in modifiers {
      let viewModifier = PreviewModifierSupport.toViewModifier(modifier: AnyPreviewModifier(modifier))
      currentView = AnyView(currentView.modifier(viewModifier))
    }
    return currentView
  }
}
