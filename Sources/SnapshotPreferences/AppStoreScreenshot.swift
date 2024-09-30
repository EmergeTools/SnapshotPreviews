//
//  AccessibiltyPreference.swift
//
//
//  Created by Noah Martin on 2/2/24.
//

import Foundation
import SwiftUI

struct AppStoreScreenshotPreferenceKey: PreferenceKey {
  static func reduce(value: inout Bool?, nextValue: () -> Bool?) {
    if value == nil {
      value = nextValue()
    }
  }

  static var defaultValue: Bool? = nil
}

extension View {
    /// Marks a screenshot for use with our App Store screenshot editing tool.
    ///
    /// - Note: This method is only available on iOS. It is unavailable on macOS, watchOS, visionOS, and tvOS.
    ///
    /// - Parameter enabled: A Boolean value that determines whether the snapshot is for an App Store screenshot.
    ///   If `nil`, the effect will default to `false`.
    ///
    /// - Returns: A view with the app store screenshot preference applied.
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
    public func emergeAppStoreScreenshot(_ enabled: Bool?) -> some View {
        preference(key: AppStoreScreenshotPreferenceKey.self, value: enabled)
    }
}
