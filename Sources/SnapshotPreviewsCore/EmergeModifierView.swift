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

  private static let modifierFinderClass =
    (NSClassFromString("EmergeModifierFinder") as? NSObject.Type)?.init()
  private static let finder =
    modifierFinderClass != nil
    ? Mirror(reflecting: modifierFinderClass!).descendant("finder")
      as? (any View) -> any View : nil
  private static let modifierState =
    NSClassFromString("EmergeModifierState") as? NSObject.Type
  private static let stateMirror =
    modifierState != nil
    ? Mirror(
      reflecting: modifierState!
        .perform(NSSelectorFromString("shared"))
        .takeUnretainedValue()
    ) : nil

  private let internalView: AnyView

  init(wrapped: some View) {
    let rootView = Self.finder?(wrapped)
    internalView = rootView != nil ? AnyView(rootView!) : AnyView(wrapped)
  }

  public var body: some View {
    internalView
  }

  var emergeRenderingMode: EmergeRenderingMode? {
    let renderingMode =
      Self.stateMirror?.descendant("renderingMode")
      as? EmergeRenderingMode.RawValue
    return renderingMode != nil
      ? EmergeRenderingMode(rawValue: renderingMode!) : nil
  }

  var accessibilityEnabled: Bool? {
    Self.stateMirror?.descendant("accessibilityEnabled") as? Bool
  }

  var appStoreSnapshot: Bool? {
    Self.stateMirror?.descendant("appStoreSnapshot") as? Bool
  }

  var precision: Float? {
    Self.stateMirror?.descendant("precision") as? Float
  }

  var supportsExpansion: Bool {
    Self.stateMirror?.descendant("expansionPreference") as? Bool ?? true
  }
}
