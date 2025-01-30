//
//  PrecisionPreference.swift
//  
//
//  Created by Noah Martin on 9/5/23.
//

import Foundation
import SwiftUI

struct PrecisionPreferenceKey: PreferenceKey {
  static func reduce(value: inout Float?, nextValue: () -> Float?) {
    value = nextValue()
  }
  
  static let defaultValue: Float? = nil
}

extension View {
    /// Sets the precision level for the snapshot on the view.
    ///
    /// Use this method to control the precision of the snapshot, which will be used for
    /// the comparison logic. With precision level 1.0, the images fully match. With precision
    /// level 0, the snapshot will never be flagged for having differences.
    ///
    /// - Parameter precision: A Float value representing the desired precision level for
    ///   emerge snapshot operations. If `nil`, the value will default to 1.0.
    ///
    /// - Returns: A view with the snapshot precision preference applied.
    ///
    /// # Example
    /// ```swift
    /// struct ContentView: View {
    ///     var body: some View {
    ///         Image("sample")
    ///             .emergeSnapshotPrecision(0.8)
    ///     }
    /// }
    /// ```
    ///
    /// - Note: The actual impact of the precision value may vary depending on the
    ///   specific implementation of the emerge snapshot feature.
    public func emergeSnapshotPrecision(_ precision: Float?) -> some View {
        preference(key: PrecisionPreferenceKey.self, value: precision)
    }
}
