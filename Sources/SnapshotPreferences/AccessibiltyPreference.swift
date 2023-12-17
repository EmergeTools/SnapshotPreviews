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
  public func emergeAccessibility(_ enabled: Bool?) -> some View {
    preference(key: AccessibilityPreferenceKey.self, value: enabled)
  }
}
