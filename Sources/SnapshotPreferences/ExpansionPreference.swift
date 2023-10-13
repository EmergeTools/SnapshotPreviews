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
  public func emergeExpansion(_ enabled: Bool?) -> some View {
    preference(key: ExpansionPreferenceKey.self, value: enabled)
  }
}
