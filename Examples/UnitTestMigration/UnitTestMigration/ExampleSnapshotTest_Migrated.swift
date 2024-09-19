//
//  ExampleSnapshotTest_Migrated.swift
//  UnitTestMigration
//
//  Created by Noah Martin on 9/19/24.
//

import SwiftUI

// Add the conformance to `PreviewProvider` when extending `SnapshotTest`
class ExampleSnapshotTest: SnapshotTest, PreviewProvider {

  func testContentViewSnapshot() {
    assertSnapshot(of: ContentView(), as: .image)
  }
}
