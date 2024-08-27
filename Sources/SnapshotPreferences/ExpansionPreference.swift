//
//  ExpansionPreference.swift
//
//
//  Created by Noah Martin on 9/7/23.
//

import Foundation
import SwiftUI

struct ExpansionPreferenceKey: PreferenceKey {
  static func reduce(value: inout Bool?, nextValue: () -> Bool?) {
    if value == nil {
      value = nextValue()
    }
  }

  static var defaultValue: Bool? = nil
}

extension View {
    /// Applies an expansion effect to the view's snapshot.
    ///
    /// Use this method to control the emerge expansion effect on a view. When enabled,
    /// the view's first scrollview will be expanded to show all content in the snapshot.
    ///
    /// - Parameter enabled: A Boolean value that determines whether the emerge expansion
    ///   effect is applied. If `nil`, the effect will default to `true`.
    ///
    /// - Returns: A view with the expansion preference applied.
    ///
    /// # Example
    /// ```swift
    /// struct ContentView: View {
    ///     var body: some View {
    ///         Text("Hello, World!")
    ///             .emergeExpansion(false)
    ///     }
    /// }
    /// ```
    public func emergeExpansion(_ enabled: Bool?) -> some View {
        preference(key: ExpansionPreferenceKey.self, value: enabled)
    }
}
