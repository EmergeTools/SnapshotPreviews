//
//  EmergeRenderingMode.swift
//  
//
//  Created by Noah Martin on 10/6/23.
//

import Foundation

public enum EmergeRenderingMode: Int {
  // Renders using CALayer render(in:)
  case coreAnimation
  // Renders using UIView drawHierarchy(in: , afterScreenUpdates: true)
  case uiView
}
