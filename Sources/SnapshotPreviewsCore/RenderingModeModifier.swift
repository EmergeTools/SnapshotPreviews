//
//  ExpansionModifier.swift
//
//
//  Created by Noah Martin on 9/7/23.
//

import Foundation
import SwiftUI

public enum EmergeRenderingMode {
  // Renders using CALayer render(in:)
  case coreAnimation
  // Renders using UIView drawHierarchy(in: , afterScreenUpdates: true)
  case uiView
}

public struct RenderingModeModifier: ViewModifier {
  let renderingMode: EmergeRenderingMode?

  public func body(content: Content) -> some View {
    content
  }
}

extension View {
  public func emergeRenderingMode(_ renderingMode: EmergeRenderingMode?) -> some View {
    modifier(RenderingModeModifier(renderingMode: renderingMode))
  }
}
