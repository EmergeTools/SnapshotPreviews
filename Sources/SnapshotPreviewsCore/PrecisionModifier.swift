//
//  PrecisionModifier.swift
//  
//
//  Created by Noah Martin on 9/5/23.
//

import Foundation
import SwiftUI

public struct EmergePrecisionModifier: ViewModifier {
  let precision: Float?

  public func body(content: Content) -> some View {
    content
  }
}

extension View {
  public func emergeSnapshotPrecision(_ precision: Float?) -> some View {
    modifier(EmergePrecisionModifier(precision: precision))
  }
}
