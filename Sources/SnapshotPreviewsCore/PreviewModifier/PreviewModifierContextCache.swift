//
//  PreviewModifierContextCache.swift
//  SnapshotPreviews
//
//  Created by Itay Brenner on 26/9/24.
//

import SwiftUI

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, *)
struct PreviewModifierContextCache {
  static var contextCache: [String: Any] = [:]
}
