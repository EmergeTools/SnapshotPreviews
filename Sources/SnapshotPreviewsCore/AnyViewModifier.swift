//
//  AnyViewModifier.swift
//  
//
//  Created by Noah Martin on 8/4/23.
//

import SwiftUI

public struct AnyViewModifier: ViewModifier {
  public func body(content: Content) -> some View {
    modifier(content)
  }

  public init(modifier: some ViewModifier) {
    self.viewModifier = modifier
    self.modifier = { AnyView($0.modifier(modifier)) }
  }

  let viewModifier: any ViewModifier
  private let modifier: (Content) -> AnyView
}
