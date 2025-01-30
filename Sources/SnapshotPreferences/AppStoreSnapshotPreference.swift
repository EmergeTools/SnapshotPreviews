//
//  AppStoreSnapshotPreference.swift
//
//
//  Created by Trevor Elkins on 09/30/24.
//

import Foundation
import SwiftUI

struct AppStoreSnapshotPreferenceKey: PreferenceKey {
  static func reduce(value: inout Bool?, nextValue: () -> Bool?) {
    if value == nil {
      value = nextValue()
    }
  }

  static let defaultValue: Bool? = nil
}

extension View {
    /// Marks a snapshot for use with our App Store screenshot editing tool. This should ideally be used with a
    /// full-size preview matching one of our supported devices.
    ///
    /// - Note: This method is only available on iOS. It is unavailable on macOS, watchOS, visionOS, and tvOS.
    ///
    /// - Parameter enabled: A Boolean value that determines whether the snapshot is for an App Store screenshot.
    ///   If `nil`, the effect will default to `false`.
    ///
    /// - Returns: A view with the app store snapshot preference applied.
    ///
    /// # Example
    /// ```swift
    /// struct ContentView: View {
    ///     var body: some View {
    ///         Text("My App Store listing!")
    ///             .emergeAppStoreSnapshot(true)
    ///     }
    /// }
    /// ```
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    @available(visionOS, unavailable)
    @available(tvOS, unavailable)
    public func emergeAppStoreSnapshot(_ enabled: Bool?) -> some View {
        preference(key: AppStoreSnapshotPreferenceKey.self, value: enabled)
    }
}
