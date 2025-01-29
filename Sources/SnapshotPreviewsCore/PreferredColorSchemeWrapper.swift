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
  let colorSchemeUpdater: ((ColorScheme?) -> Void)?

  public init(@ViewBuilder _ content: () -> Content, colorSchemeUpdater: ((ColorScheme?) -> Void)? = nil) {
    self.content = content()
    self.colorSchemeUpdater = colorSchemeUpdater
  }

  public var body: some View {
    content
      .onPreferenceChange(PreferredColorSchemeKey.self, perform: { value in
        Task { @MainActor in
          preferredColorScheme = value
          colorSchemeUpdater?(value)
        }
      })
      .environment(\.colorScheme, preferredColorScheme ?? colorScheme)
      .preferredColorScheme(nil)
  }
}
