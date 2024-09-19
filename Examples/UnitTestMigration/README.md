# Unit Test Migration

This example shows how to migrate from swift-snapshot-testing to preview providers. The example app contains a unit test target `UnitTestMigrationTests` with one [snapshot test](https://github.com/EmergeTools/SnapshotPreviews-iOS/blob/main/Examples/UnitTestMigration/UnitTestMigrationTests/ExampleSnapshotTest.swift). It has been migrated by copying/pasting the file into the main app target as [ExampleSnapshotTest_Migrated.swift](https://github.com/EmergeTools/SnapshotPreviews-iOS/blob/main/Examples/UnitTestMigration/UnitTestMigration/ExampleSnapshotTest_Migrated.swift). The test is modified by removing the XCTest/SnapshotTesting importants, changing the base class to `SnapshotTest` and adding the conformance to `PreviewProvider`.

## Migrating your own tests

1. Add the file [SnapshotTest.swift](https://github.com/EmergeTools/SnapshotPreviews-iOS/blob/main/Examples/UnitTestMigration/UnitTestMigration/SnapshotTest.swift) to your app, this does the heavy lifting of converting snapshot test function calls into previews.
2. Copy your test file from the unit test target to your application.
3. Remove imports of `XCTest` and `SnapshotTesting`.
4. Change the base class from `XCTestCase` to `SnapshotTest` and add a conformce to `PreviewProvider`.

Here’s a complete example of a migrated test:

```swift
import SwiftUI

// Add the conformance to `PreviewProvider` when extending `SnapshotTest`
// The `SnapshotTest` base class automatically handles turning calls to
// assertSnapshot into previews.
class ExampleSnapshotTest: SnapshotTest, PreviewProvider {

  func testContentViewSnapshot() {
    assertSnapshot(of: ContentView(), as: .image)
  }
}
```
