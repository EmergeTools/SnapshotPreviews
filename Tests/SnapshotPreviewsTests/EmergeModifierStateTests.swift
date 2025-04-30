//
//  EmergeModifierViewTests.swift
//  SnapshotPreviews
//
//  Created by Trevor Elkins on 4/30/25.
//

import SwiftUI
import XCTest

@testable import SnapshotPreferences
@testable import SnapshotSharedModels
@testable import SnapshotPreviewsCore

final class EmergeModifierStateTests: XCTestCase {

  override func setUp() {
    super.setUp()
    EmergeModifierState.shared.reset()
  }

  func testStoresRenderingMode() {
    let view = makeBaseText().emergeRenderingMode(.uiView)
    let state = state(for: view)
    XCTAssertEqual(state.renderingMode, EmergeRenderingMode.uiView.rawValue)
  }

  func testStoresPrecision() throws {
    let view = makeBaseText().emergeSnapshotPrecision(0.95)
    let state = state(for: view)
    let precision = try XCTUnwrap(state.precision)
    XCTAssertEqual(precision, 0.95, accuracy: .ulpOfOne)
  }

  func testStoresExpansionPreference() {
    let view = makeBaseText().emergeExpansion(false)
    let state = state(for: view)
    XCTAssertEqual(state.expansionPreference, false)
  }

  func testStoresAccessibilityFlag() {
    let view = makeBaseText().emergeAccessibility(true)
    let state = state(for: view)
    XCTAssertEqual(state.accessibilityEnabled, true)
  }

  func testStoresAppStoreSnapshotFlag() {
    let view = makeBaseText().emergeAppStoreSnapshot(true)
    let state = state(for: view)
    XCTAssertEqual(state.appStoreSnapshot, true)
  }

  private func makeBaseText() -> Text { Text("Hello") }

  private func state(
    for view: some View,
    file: StaticString = #file,
    line: UInt = #line
  ) -> EmergeModifierState {
    let wrapped = EmergeModifierView(wrapped: view)
    let hosting = UIHostingController(rootView: wrapped)

    let window = UIWindow(frame: UIScreen.main.bounds)
    window.rootViewController = hosting
    window.makeKeyAndVisible()

    // Give SwiftUI one tick to propagate preferences
    RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.01))

    return EmergeModifierState.shared
  }
}
