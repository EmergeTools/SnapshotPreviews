//
//  SnapshotCIExportCoordinatorTests.swift
//  SnapshottingTestsTests
//

import Foundation
import XCTest
@testable import SnapshottingTests
import SnapshotPreviewsCore

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

@MainActor
final class SnapshotCIExportCoordinatorTests: XCTestCase {

  private var tempDir: URL!

  override func setUp() {
    super.setUp()
    tempDir = FileManager.default.temporaryDirectory
      .appendingPathComponent("SnapshotCIExportTests-\(UUID().uuidString)")
  }

  override func tearDown() {
    try? FileManager.default.removeItem(at: tempDir)
    super.tearDown()
  }

  // MARK: - Factory

  func testCreateFromEnvironmentReturnsNilWhenEnvVarAbsent() {
    let coordinator = SnapshotCIExportCoordinator.createFromEnvironment(environment: [:])
    XCTAssertNil(coordinator)
  }

  func testCreateFromEnvironmentReturnsCoordinatorWhenEnvVarSet() {
    let coordinator = SnapshotCIExportCoordinator.createFromEnvironment(
      environment: [SnapshotCIExportCoordinator.envKey: tempDir.path]
    )
    XCTAssertNotNil(coordinator)
    XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.path))
  }

  // MARK: - Filename Sanitization

  func testSanitizeReplacesUnsafeCharacters() {
    let result = SnapshotCIExportCoordinator.sanitize("My/View:Preview 1")
    let unsafeChars = CharacterSet(charactersIn: "/\\: \"'<>|?*")
    XCTAssertNil(result.rangeOfCharacter(from: unsafeChars))
  }

  func testSanitizeIsDeterministic() {
    let a = SnapshotCIExportCoordinator.sanitize("Some/View:Name")
    let b = SnapshotCIExportCoordinator.sanitize("Some/View:Name")
    XCTAssertEqual(a, b)
  }

  func testSanitizeCollapsesRepeatedUnsafeCharacters() {
    let result = SnapshotCIExportCoordinator.sanitize("A///B   C")
    XCTAssertFalse(result.contains("__"), "Consecutive unsafe chars should collapse to a single underscore")
  }

  func testSanitizePreservesExistingUnderscores() {
    let result = SnapshotCIExportCoordinator.sanitize("A___B")
    XCTAssertEqual(result, "A___B", "Underscores in the input should be preserved as-is")
  }

  func testSanitizeFallsBackForEmptyResult() {
    let result = SnapshotCIExportCoordinator.sanitize("///")
    XCTAssertEqual(result, "snapshot")
  }

  func testSanitizePreservesAlphanumericAndSafeChars() {
    let result = SnapshotCIExportCoordinator.sanitize("Hello_World-2.0")
    XCTAssertEqual(result, "Hello_World-2.0")
  }

  func testResolvedFileNameComponentUsesDisplayNameWhenUnique() {
    let component = SnapshotTest.resolvedFileNameComponent(
      fileId: nil,
      line: nil,
      previewDisplayName: "Dark Mode",
      previewIndex: 1,
      duplicateDisplayNameCount: 1
    )

    XCTAssertEqual(component, "Dark Mode")
  }

  func testResolvedFileNameComponentFallsBackToLineForDuplicatePreviewMacroDisplayNames() {
    let component = SnapshotTest.resolvedFileNameComponent(
      fileId: "Feature/LoginView.swift",
      line: 42,
      previewDisplayName: "Dark Mode",
      previewIndex: 0,
      duplicateDisplayNameCount: 2
    )

    XCTAssertEqual(component, "line-42")
  }

  func testResolvedFileNameComponentFallsBackToIndexForDuplicatePreviewProviderDisplayNames() {
    let component = SnapshotTest.resolvedFileNameComponent(
      fileId: nil,
      line: nil,
      previewDisplayName: "Dark Mode",
      previewIndex: 3,
      duplicateDisplayNameCount: 2
    )

    XCTAssertEqual(component, "3")
  }

  // MARK: - Successful Export

  func testSuccessfulExportWritesPngAndSidecar() throws {
    let coordinator = SnapshotCIExportCoordinator(exportDirectoryURL: tempDir)
    let context = makeContext(baseFileName: "TestView_Preview")

    coordinator.enqueueExport(result: makeSuccessResult(), context: context)
    coordinator.drain()

    let jsonURL = tempDir.appendingPathComponent("\(context.baseFileName).json")
    let pngURL = tempDir.appendingPathComponent("\(context.baseFileName).png")

    XCTAssertTrue(FileManager.default.fileExists(atPath: jsonURL.path))
    XCTAssertTrue(FileManager.default.fileExists(atPath: pngURL.path))
  }

  // MARK: - Sidecar Content

  func testSidecarUsesPreviewDisplayNameAndTypeDisplayNameForPreviewProviderPresentation() throws {
    let coordinator = SnapshotCIExportCoordinator(exportDirectoryURL: tempDir)
    let context = makeContext(
      baseFileName: "Login_Screen_Dark_Mode",
      typeName: "MyModule.LoginScreen_Previews",
      typeDisplayName: "Login Screen",
      previewDisplayName: "Dark Mode"
    )

    coordinator.enqueueExport(result: makeSuccessResult(), context: context)
    coordinator.drain()

    let json = try readJSON(forBaseFileName: context.baseFileName)

    XCTAssertEqual(json["image_file_name"] as? String, context.baseFileName)
    XCTAssertEqual(json["display_name"] as? String, "Dark Mode")
    XCTAssertEqual(json["group"] as? String, "Login Screen")
  }

  func testSidecarGroupPrefersFileIdForPreviewMacro() throws {
    let coordinator = SnapshotCIExportCoordinator(exportDirectoryURL: tempDir)
    let context = makeContext(
      baseFileName: "Feature_LoginView.swift_line-42",
      typeName: "$s7MyApp11LoginViewV13Preview_42fMf_15LLPreviewRegistryMc",
      typeDisplayName: "Login View",
      fileId: "Feature/LoginView.swift",
      line: 42,
      previewDisplayName: nil
    )

    coordinator.enqueueExport(result: makeSuccessResult(), context: context)
    coordinator.drain()

    let json = try readJSON(forBaseFileName: context.baseFileName)

    XCTAssertEqual(json["group"] as? String, "Feature/LoginView.swift")
  }

  func testSidecarDisplayNameFallsBackToAtLineForAnonymousPreviewMacroPresentation() throws {
    let coordinator = SnapshotCIExportCoordinator(exportDirectoryURL: tempDir)
    let context = makeContext(
      baseFileName: "Feature_LoginView.swift_line-42",
      fileId: "Feature/LoginView.swift",
      line: 42,
      previewDisplayName: nil
    )

    coordinator.enqueueExport(result: makeSuccessResult(), context: context)
    coordinator.drain()

    let json = try readJSON(forBaseFileName: context.baseFileName)

    XCTAssertEqual(json["display_name"] as? String, "At line #42")
  }

  func testSidecarDisplayNameFallsBackToIndexForUnnamedPreviewProviderVariantPresentation() throws {
    let coordinator = SnapshotCIExportCoordinator(exportDirectoryURL: tempDir)
    let context = makeContext(
      baseFileName: "TestView_0",
      fileId: nil,
      line: nil,
      previewDisplayName: nil,
      previewId: "0",
      previewIndex: 0
    )

    coordinator.enqueueExport(result: makeSuccessResult(), context: context)
    coordinator.drain()

    let json = try readJSON(forBaseFileName: context.baseFileName)

    XCTAssertEqual(json["display_name"] as? String, "0")
  }

  func testSidecarGroupFallsBackToTypeNameWhenPreviewProviderDisplayNameUnavailable() throws {
    let coordinator = SnapshotCIExportCoordinator(exportDirectoryURL: tempDir)
    let context = makeContext(
      baseFileName: "MyModule.TestView_Previews_0",
      typeName: "MyModule.TestView_Previews",
      typeDisplayName: "",
      fileId: nil,
      line: nil,
      previewDisplayName: nil
    )

    coordinator.enqueueExport(result: makeSuccessResult(), context: context)
    coordinator.drain()

    let json = try readJSON(forBaseFileName: context.baseFileName)

    XCTAssertEqual(json["group"] as? String, "MyModule.TestView_Previews")
  }

  func testSidecarFlattensContextFields() throws {
    let coordinator = SnapshotCIExportCoordinator(exportDirectoryURL: tempDir)
    let context = makeContext(
      baseFileName: "TestView_Preview",
      line: 99,
      previewId: "7",
      colorScheme: "dark"
    )

    coordinator.enqueueExport(result: makeSuccessResult(), context: context)
    coordinator.drain()

    let json = try readJSON(forBaseFileName: context.baseFileName)

    XCTAssertEqual(json["type_name"] as? String, context.typeName)
    XCTAssertEqual(json["orientation"] as? String, "portrait")
    XCTAssertEqual(json["preview_id"] as? String, "7")
    XCTAssertEqual(json["line"] as? Int, 99)
    XCTAssertEqual(json["color_scheme"] as? String, "dark")
    XCTAssertNil(json["context"])
  }

  // MARK: - Render Failure

  func testRenderFailureProducesNoFiles() {
    let coordinator = SnapshotCIExportCoordinator(exportDirectoryURL: tempDir)
    let context = makeContext(baseFileName: "TestView_Preview")

    coordinator.enqueueExport(result: makeFailureResult(), context: context)
    coordinator.drain()

    XCTAssertFalse(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("\(context.baseFileName).png").path))
    XCTAssertFalse(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("\(context.baseFileName).json").path))
  }

  // MARK: - Drain Semantics

  func testDrainIsIdempotent() throws {
    let coordinator = SnapshotCIExportCoordinator(exportDirectoryURL: tempDir)
    let context = makeContext(baseFileName: "TestView_Preview")
    coordinator.enqueueExport(result: makeSuccessResult(), context: context)

    coordinator.drain()
    coordinator.drain()

    XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("\(context.baseFileName).json").path))
  }

  func testDrainOnEmptyQueueDoesNotCrash() {
    let coordinator = SnapshotCIExportCoordinator(exportDirectoryURL: tempDir)
    coordinator.drain()
  }

  // MARK: - Multiple Exports

  func testMultipleExportsProduceIndividualFiles() throws {
    let coordinator = SnapshotCIExportCoordinator(exportDirectoryURL: tempDir)

    let contexts = (0..<5).map { i in
      makeContext(
        baseFileName: "View\(i)_Preview",
        typeName: "Module.View\(i)",
        previewId: "\(i)",
        previewIndex: i
      )
    }

    for context in contexts {
      coordinator.enqueueExport(result: makeSuccessResult(), context: context)
    }
    coordinator.drain()

    for context in contexts {
      XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("\(context.baseFileName).png").path))
      XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("\(context.baseFileName).json").path))
    }
  }
}

// MARK: - Test Helpers

extension SnapshotCIExportCoordinatorTests {

  private func readJSON(forBaseFileName baseFileName: String) throws -> [String: Any] {
    let data = try Data(contentsOf: tempDir.appendingPathComponent("\(baseFileName).json"))
    return try JSONSerialization.jsonObject(with: data) as! [String: Any]
  }

  private func makeContext(
    baseFileName: String,
    typeName: String = "MyModule.TestView_Previews",
    typeDisplayName: String = "Test View",
    fileId: String? = nil,
    line: Int? = nil,
    previewDisplayName: String? = "Preview",
    previewId: String = "0",
    previewIndex: Int = 0,
    colorScheme: String? = nil
  ) -> SnapshotContext {
    SnapshotContext(
      baseFileName: baseFileName,
      testName: "-[MyTests testPreview]",
      typeName: typeName,
      typeDisplayName: typeDisplayName,
      fileId: fileId,
      line: line,
      previewDisplayName: previewDisplayName,
      previewIndex: previewIndex,
      previewId: previewId,
      orientation: "portrait",
      declaredDevice: nil,
      simulatorDeviceName: nil,
      simulatorModelIdentifier: nil,
      precision: nil,
      accessibilityEnabled: nil,
      colorScheme: colorScheme,
      appStoreSnapshot: nil
    )
  }

  private func makeTestImage() -> ImageType {
    #if canImport(UIKit)
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
    return renderer.image { ctx in
      UIColor.red.setFill()
      ctx.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
    }
    #else
    let rep = NSBitmapImageRep(
      bitmapDataPlanes: nil,
      pixelsWide: 1,
      pixelsHigh: 1,
      bitsPerSample: 8,
      samplesPerPixel: 4,
      hasAlpha: true,
      isPlanar: false,
      colorSpaceName: .deviceRGB,
      bytesPerRow: 0,
      bitsPerPixel: 0
    )!
    let image = NSImage(size: NSSize(width: 1, height: 1))
    image.addRepresentation(rep)
    return image
    #endif
  }

  private func makeSuccessResult() -> SnapshotResult {
    SnapshotResult(
      image: .success(makeTestImage()),
      precision: nil,
      accessibilityEnabled: nil,
      colorScheme: nil,
      appStoreSnapshot: nil
    )
  }

  private func makeFailureResult() -> SnapshotResult {
    SnapshotResult(
      image: .failure(NSError(domain: "test", code: 1)),
      precision: nil,
      accessibilityEnabled: nil,
      colorScheme: nil,
      appStoreSnapshot: nil
    )
  }
}
