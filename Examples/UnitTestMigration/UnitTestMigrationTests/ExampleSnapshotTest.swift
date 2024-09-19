//
//  ExampleSnapshotTest.swift
//  UnitTestMigrationTests
//
//  Created by Noah Martin on 9/19/24.
//

import XCTest
import SnapshotTesting
@testable import UnitTestMigration

class ExampleSnapshotTest: XCTestCase {
  func testContentViewSnapshot() {
    assertSnapshot(of: ContentView(), as: .image)
  }
}
