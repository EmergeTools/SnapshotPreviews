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

  /// Renders the entire window instead of the previewed view.
  /// This uses UIWindow.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
  case window
}
