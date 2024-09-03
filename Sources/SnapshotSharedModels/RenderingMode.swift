//
//  EmergeRenderingMode.swift
//
//
//  Created by Noah Martin on 10/6/23.
//

import Foundation


/// Specifies the rendering mode for the Emerge framework.
///
/// This enum defines different methods for rendering views,
/// allowing you to choose between Core Animation and UIView-based rendering.
public enum EmergeRenderingMode: Int {
  /// Renders using `CALayer.render(in:)`.
  case coreAnimation

  /// Renders using `UIView.drawHierarchy(in:afterScreenUpdates:true)`.
  case uiView
}
