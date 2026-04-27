import ModuleA
import ModuleB
import ModuleC
import SnapshotPreviewsCore
import XCTest

@MainActor
final class ModuleFilterAssertionTests: XCTestCase {
  func testNoFilterReturnsAllPreviewTypesAcrossModules() {
    let previews = FindPreviews.findPreviews(
      included: nil,
      excluded: nil,
      includedModules: nil,
      excludedModules: nil
    )

    XCTAssertEqual(previews.count, 8)
    XCTAssertTrue(previews.contains { $0.typeName.hasPrefix("ModuleA.") })
    XCTAssertTrue(previews.contains { $0.typeName.hasPrefix("ModuleB.") })
    XCTAssertTrue(previews.contains { $0.typeName.hasPrefix("ModuleC.") })
  }

  func testIncludeModulesReturnsOnlyMatchingModule() {
    let previews = FindPreviews.findPreviews(
      included: nil,
      excluded: nil,
      includedModules: ["ModuleA"],
      excludedModules: nil
    )

    XCTAssertFalse(previews.isEmpty)
    XCTAssertTrue(previews.allSatisfy { $0.typeName.hasPrefix("ModuleA.") })
  }

  func testExcludeModulesDropsMatchingModule() {
    let previews = FindPreviews.findPreviews(
      included: nil,
      excluded: nil,
      includedModules: nil,
      excludedModules: ["ModuleA"]
    )

    XCTAssertFalse(previews.contains { $0.typeName.hasPrefix("ModuleA.") })
    XCTAssertTrue(previews.contains { $0.typeName.hasPrefix("ModuleB.") })
    XCTAssertTrue(previews.contains { $0.typeName.hasPrefix("ModuleC.") })
  }

  func testIncludeMultipleModules() {
    let previews = FindPreviews.findPreviews(
      included: nil,
      excluded: nil,
      includedModules: ["ModuleA", "ModuleC"],
      excludedModules: nil
    )

    XCTAssertFalse(previews.isEmpty)
    XCTAssertTrue(previews.allSatisfy { preview in
      preview.typeName.hasPrefix("ModuleA.") || preview.typeName.hasPrefix("ModuleC.")
    })
    XCTAssertTrue(previews.contains { $0.typeName.hasPrefix("ModuleA.") })
    XCTAssertTrue(previews.contains { $0.typeName.hasPrefix("ModuleC.") })
  }

  func testExcludeWinsOverInclude() {
    let previews = FindPreviews.findPreviews(
      included: nil,
      excluded: nil,
      includedModules: ["ModuleA"],
      excludedModules: ["ModuleA"]
    )

    XCTAssertTrue(previews.isEmpty)
  }

  func testNonexistentModuleReturnsEmpty() {
    let previews = FindPreviews.findPreviews(
      included: nil,
      excluded: nil,
      includedModules: ["BogusModule"],
      excludedModules: nil
    )

    XCTAssertTrue(previews.isEmpty)
  }

  func testExactMatchSemantics() {
    let previews = FindPreviews.findPreviews(
      included: nil,
      excluded: nil,
      includedModules: ["Module"],
      excludedModules: nil
    )

    XCTAssertTrue(previews.isEmpty)
  }
}
