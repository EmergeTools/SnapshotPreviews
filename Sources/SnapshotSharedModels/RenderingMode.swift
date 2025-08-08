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
  @available(macOS, unavailable)
  case uiView
    
  /// Renders using `NSView.bitmapImageRepForCachingDisplay`.
  @available(iOS, unavailable)
  case nsView

  /// Renders the entire window instead of the previewed view.
  /// This uses `UIWindow.drawHierarchy(in: window.bounds, afterScreenUpdates: true)` on iOS
  /// This uses `CGWindowListCreateImage` on macOS.
  case window
}
