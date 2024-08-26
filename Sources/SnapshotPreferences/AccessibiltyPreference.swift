//
//  AccessibiltyPreference.swift
//
//
//  Created by Noah Martin on 2/2/24.
//

import Foundation
import SwiftUI

struct AccessibilityPreferenceKey: PreferenceKey {
  static func reduce(value: inout Bool?, nextValue: () -> Bool?) {
    if value == nil {
      value = nextValue()
    }
  }

  static var defaultValue: Bool? = nil
}

extension View {
    /// Applies accessibility support to the view's snapshot.
    ///
    /// Use this method to control whether the snapshot should render with accessibility elements
    /// highlighted as well as a corresponding legend for them.
    ///
    /// - Note: This method is only available on iOS. It is unavailable on macOS, watchOS, visionOS, and tvOS.
    ///
    /// - Parameter enabled: A Boolean value that determines whether the emerge accessibility
    ///   features are applied. If `nil`, the effect will default to `false`.
    ///
    /// - Returns: A view with the accessibility preference applied.
    ///
    /// # Example
    /// ```swift
    /// struct ContentView: View {
    ///     var body: some View {
    ///         Text("Accessible Content")
    ///             .emergeAccessibility(true)
    ///     }
    /// }
    /// ```
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    @available(visionOS, unavailable)
    @available(tvOS, unavailable)
    public func emergeAccessibility(_ enabled: Bool?) -> some View {
        preference(key: AccessibilityPreferenceKey.self, value: enabled)
    }
}
