//
//  ExpansionModifier.swift
//
//
//  Created by Noah Martin on 9/7/23.
//

import Foundation
import SwiftUI

public struct EmergeExpansionModifier: ViewModifier {
  let enabled: Bool?

  public func body(content: Content) -> some View {
    content
  }
}

extension View {
  public func emergeExpansion(_ enabled: Bool?) -> some View {
    modifier(EmergeExpansionModifier(enabled: enabled))
  }
}
