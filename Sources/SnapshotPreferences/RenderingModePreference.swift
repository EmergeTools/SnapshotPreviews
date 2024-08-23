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
  @available(iOS 15, *)
  public func emergeRenderingMode(_ renderingMode: EmergeRenderingMode?) -> some View {
    preference(key: RenderingModePreferenceKey.self, value: renderingMode?.rawValue)
  }
}
