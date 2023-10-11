//
//  File.swift
//  
//
//  Created by Noah Martin on 10/11/23.
//

import Foundation
import SwiftUI

public struct PreferredColorSchemeWrapper<Content: View>: View {

  @State var preferredColorScheme: ColorScheme? = nil
  @Environment(\.colorScheme) var colorScheme

  let content: Content

  public init(@ViewBuilder _ content: () -> Content) {
    self.content = content()
  }

  public var body: some View {
    content
      .onPreferenceChange(PreferredColorSchemeKey.self, perform: { value in
        preferredColorScheme = value
      })
      .environment(\.colorScheme, preferredColorScheme ?? colorScheme)
      .preferredColorScheme(nil)
  }
}
