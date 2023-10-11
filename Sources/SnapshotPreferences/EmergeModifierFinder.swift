//
//  EmergeModifierFinder.swift
//
//
//  Created by Noah Martin on 10/6/23.
//

import Foundation
import SwiftUI
import SnapshotPreviewsCore

// Classes in this file get compiled to an app that use any of the custom preview preferences.
// The inserted test runner code finds these classes through ObjC runtime functions (NSClassFromString)
// and Swift reflection (Mirror).

@objc(EmergeModifierState)
class EmergeModifierState: NSObject {

  @objc
  static let shared = EmergeModifierState()

  func reset() {
    expansionPreference = nil
    renderingMode = nil
    precision = nil
  }

  var expansionPreference: Bool?
  var renderingMode: EmergeRenderingMode.RawValue?
  var precision: Float?
}

@objc(EmergeModifierFinder)
class EmergeModifierFinder: NSObject {
  let finder: (any View) -> (any View) = { view in
    EmergeModifierState.shared.reset()
    return view
      .onPreferenceChange(ExpansionPreferenceKey.self, perform: { value in
        EmergeModifierState.shared.expansionPreference = value
      })
      .onPreferenceChange(RenderingModePreferenceKey.self, perform: { value in
        EmergeModifierState.shared.renderingMode = value
      })
      .onPreferenceChange(PrecisionPreferenceKey.self, perform: { value in
        EmergeModifierState.shared.precision = value
      })
  }
}
