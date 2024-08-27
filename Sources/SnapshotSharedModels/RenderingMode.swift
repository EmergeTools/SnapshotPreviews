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
    ///
    /// This mode utilizes Core Animation's rendering capabilities, which can be more
    /// performant for certain types of animations and effects.
    case coreAnimation

    /// Renders using `UIView.drawHierarchy(in:afterScreenUpdates:true)`.
    ///
    /// This mode uses UIKit's view hierarchy drawing method, which can capture a more
    /// accurate representation of the view, including any custom drawing or CoreGraphics
    /// content.
    case uiView
}
