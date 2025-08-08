//
//  RenderingModePreference.swift
//
//
//  Created by Noah Martin on 9/7/23.
//

import Foundation
import SwiftUI
import SnapshotSharedModels

struct RenderingModePreferenceKey: PreferenceKey {
  static func reduce(value: inout Int?, nextValue: () -> Int?) {
    value = nextValue()
  }
  
  static var defaultValue: EmergeRenderingMode.RawValue? = nil
}

extension View {
    /// Sets the emerge rendering mode for the view.
    ///
    /// Use this method to control how the view is rendered for snapshots. You can indicate whether
    /// to use `.coreAnimation` which will use the CALayer from Quartz or `.uiView` which will use
    /// UIKit's `drawViewHierarchyInRect` under the hood.
    ///
    /// - Note: This method is only available on iOS. It is unavailable on macOS, watchOS, visionOS, and tvOS.
    ///
    /// - Parameter renderingMode: An `EmergeRenderingMode` value that specifies the
    ///   desired rendering mode for snapshots. If `nil`, the default rendering
    ///   mode will be selected based off of the view's height.
    ///
    /// - Returns: A view with the specified rendering mode preference applied.
    ///
    /// # Example
    /// ```swift
    /// struct ContentView: View {
    ///     var body: some View {
    ///         Text("Emerge Effect")
    ///             .emergeRenderingMode(.coreAnimation)
    ///     }
    /// }
    /// ```
    ///
    /// - SeeAlso: `EmergeRenderingMode`
    @available(watchOS, unavailable)
    @available(visionOS, unavailable)
    @available(tvOS, unavailable)
    public func emergeRenderingMode(_ renderingMode: EmergeRenderingMode?) -> some View {
        preference(key: RenderingModePreferenceKey.self, value: renderingMode?.rawValue)
    }
}
