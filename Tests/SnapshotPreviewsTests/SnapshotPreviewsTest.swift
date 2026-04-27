import XCTest
@testable import SnapshotPreviewsCore

final class SnapshotPreviewsTest: XCTestCase {
  func testModuleNameUsesPrefixBeforeFirstDot() {
    XCTAssertEqual(FindPreviews.moduleName(typeName: "MyModule.MyView_Previews"), "MyModule")
    XCTAssertEqual(FindPreviews.moduleName(typeName: "SingleName"), "SingleName")
  }

  func testShouldIncludeModuleReturnsFalseWhenModuleIsExcluded() {
    let includedModulesSet: Set<String>? = ["MyModule"]
    let excludedModulesSet: Set<String>? = ["MyModule"]

    XCTAssertFalse(
      FindPreviews.shouldIncludeModule(
        typeName: "MyModule.MyView_Previews",
        includedModulesSet: includedModulesSet,
        excludedModulesSet: excludedModulesSet
      )
    )
  }

  func testShouldIncludeModuleReturnsFalseWhenNotInIncludedList() {
    let includedModulesSet: Set<String>? = ["FeatureModule"]

    XCTAssertFalse(
      FindPreviews.shouldIncludeModule(
        typeName: "OtherModule.MyView_Previews",
        includedModulesSet: includedModulesSet,
        excludedModulesSet: nil
      )
    )
  }

  func testShouldIncludeModuleUsesExactMatch() {
    let includedModulesSet: Set<String>? = ["My"]

    XCTAssertFalse(
      FindPreviews.shouldIncludeModule(
        typeName: "MyModule.MyView_Previews",
        includedModulesSet: includedModulesSet,
        excludedModulesSet: nil
      )
    )
  }

  func testShouldIncludeModuleReturnsTrueWhenIncludedListContainsModule() {
    let includedModulesSet: Set<String>? = ["FeatureModule"]

    XCTAssertTrue(
      FindPreviews.shouldIncludeModule(
        typeName: "FeatureModule.MyView_Previews",
        includedModulesSet: includedModulesSet,
        excludedModulesSet: nil
      )
    )
  }

  func testShouldIncludeModuleReturnsTrueWhenNoListsProvided() {
    XCTAssertTrue(
      FindPreviews.shouldIncludeModule(
        typeName: "AnyModule.MyView_Previews",
        includedModulesSet: nil,
        excludedModulesSet: nil
      )
    )
  }
}
