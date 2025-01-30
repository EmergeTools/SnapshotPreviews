//
//  EmergeModifierFinder.swift
//
//
//  Created by Noah Martin on 10/6/23.
//

import Foundation
import SwiftUI
import SnapshotSharedModels

// Classes in this file get compiled to an app that use any of the custom preview preferences.
// The inserted test runner code finds these classes through ObjC runtime functions (NSClassFromString)
// and Swift reflection (Mirror).

@objc(EmergeModifierState) @MainActor
final class EmergeModifierState: NSObject {

  @MainActor @objc
  static let shared = EmergeModifierState()

  func reset() {
    expansionPreference = nil
    renderingMode = nil
    precision = nil
    accessibilityEnabled = nil
  }

  var expansionPreference: Bool?
  var renderingMode: EmergeRenderingMode.RawValue?
  var precision: Float?
  var accessibilityEnabled: Bool?
  var appStoreSnapshot: Bool?
}

@objc(EmergeModifierFinder)
class EmergeModifierFinder: NSObject {
  @MainActor
  let finder: (any View) -> (any View) = { view in
    EmergeModifierState.shared.reset()
    return view
      .onPreferenceChange(ExpansionPreferenceKey.self, perform: { value in
        Task { @MainActor in
          EmergeModifierState.shared.expansionPreference = value
        }
      })
      .onPreferenceChange(RenderingModePreferenceKey.self, perform: { value in
        Task { @MainActor in
          EmergeModifierState.shared.renderingMode = value
        }
      })
      .onPreferenceChange(PrecisionPreferenceKey.self, perform: { value in
        Task { @MainActor in
          EmergeModifierState.shared.precision = value
        }
      })
      .onPreferenceChange(AccessibilityPreferenceKey.self, perform: { value in
        Task { @MainActor in
          EmergeModifierState.shared.accessibilityEnabled = value
        }
      })
      .onPreferenceChange(AppStoreSnapshotPreferenceKey.self, perform: { value in
        Task { @MainActor in
          EmergeModifierState.shared.appStoreSnapshot = value
        }
      })
  }
}
