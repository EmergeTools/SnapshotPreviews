//
//  ModifierFinder.swift
//
//
//  Created by Noah Martin on 7/8/24.
//

import Foundation
import SnapshotSharedModels
import SwiftUI

public struct EmergeModifierView: View {

  private let internalView: AnyView
  private let stateMirror: Mirror?

  init(wrapped: some View) {
    let root = RuntimeCache.finder?(wrapped) ?? wrapped
    internalView = AnyView(root)

    stateMirror = RuntimeCache.stateMirror
  }

  public var body: some View {
    internalView
  }

  var emergeRenderingMode: EmergeRenderingMode? {
    let raw =
      stateMirror?.descendant("renderingMode") as? EmergeRenderingMode.RawValue
    return raw != nil ? EmergeRenderingMode(rawValue: raw!) : nil
  }

  var accessibilityEnabled: Bool? {
    stateMirror?.descendant("accessibilityEnabled") as? Bool
  }

  var appStoreSnapshot: Bool? {
    stateMirror?.descendant("appStoreSnapshot") as? Bool
  }

  var precision: Float? {
    stateMirror?.descendant("precision") as? Float
  }

  var supportsExpansion: Bool {
    stateMirror?.descendant("expansionPreference") as? Bool ?? true
  }
}

private enum RuntimeCache {
  static let finder: ((any View) -> any View)? = {
    guard
      let finderClass = NSClassFromString("EmergeModifierFinder")
        as? NSObject.Type,
      let closure = Mirror(reflecting: finderClass.init())
        .descendant("finder") as? ((any View) -> any View)
    else { return nil }
    return closure
  }()

  static let stateMirror: Mirror? = {
    guard
      let stateClass = NSClassFromString("EmergeModifierState")
        as? NSObject.Type,
      let shared = stateClass.perform(
        NSSelectorFromString("shared")
      )?.takeUnretainedValue()
    else { return nil }
    return Mirror(reflecting: shared)
  }()
}
