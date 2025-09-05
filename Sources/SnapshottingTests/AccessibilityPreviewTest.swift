//
//  AccessibilityPreviewTest.swift
//
//
//  Created by Noah Martin on 8/9/24.
//

import Foundation
import MachO
import XCTest

/// A base class for conducting accessibility audits on SwiftUI previews using XCTest and XCUITest.
///
/// This class provides a framework for running accessibility audits on SwiftUI previews.
/// It allows for customization of which previews to test and how to handle accessibility issues.
///
/// Usage: Create a subclass of it in your project and override any needed methods
/// (ex. you only want to check for specific accessibility audit types rather than "all").
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
open class AccessibilityPreviewTest: PreviewBaseTest {

  /// Returns an instance of XCUIApplication for testing.
  ///
  /// Override this method to provide a custom XCUIApplication instance if needed.
  ///
  /// - Returns: An instance of XCUIApplication.
  open class func getApp() -> XCUIApplication {
    XCUIApplication()
  }

  /// Specifies which previews should be snapshotted for testing.
  ///
  /// Override this method to return a list of preview type names to be tested.
  /// If not overridden, all previews will be snapshotted.
  /// Elements should be the type name of the preview, like "MyModule.MyView_Previews". This also supports Regex format.
  ///
  /// - Returns: An optional array of String
  open class func snapshotPreviews() -> [String]? {
    nil
  }

  /// Specifies which previews should be excluded from snapshotting.
  ///
  /// Override this method to return a list of preview type names to be excluded from testing.
  /// Elements should be the type name of the preview, like "MyModule.MyView_Previews". This also supports Regex format.
  ///
  /// - Returns: An optional array of Strings representing preview type names to exclude, or `nil` to exclude none.
  open class func excludedSnapshotPreviews() -> [String]? {
    nil
  }

  /// Specifies the type of accessibility audit to perform.
  ///
  /// Override this method to customize the type of accessibility audit.
  ///
  /// - Returns: An XCUIAccessibilityAuditType value. Default is `.all`.
  @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
  open func auditType() -> XCUIAccessibilityAuditType { .all }

  /// Handles accessibility audit issues.
  ///
  /// Override this method to provide custom handling of accessibility issues discovered during the audit.
  ///
  /// - Parameter issue: The XCUIAccessibilityAuditIssue to handle.
  /// - Returns: A Boolean value indicating whether the issue was handled. Return `true` if the issue was handled, `false` otherwise.
  @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
  open func handle(issue: XCUIAccessibilityAuditIssue) -> Bool { false }

  private static func getDylibPath(dylibName: String) -> String? {
    let count = _dyld_image_count()
    for i in 0..<count {
      if let imagePath = _dyld_get_image_name(i) {
        let imagePathStr = String(cString: imagePath)
        if (imagePathStr as NSString).lastPathComponent == dylibName {
          return imagePathStr
        }
      }
    }
    return nil
  }

  override class func discoverPreviews() -> [DiscoveredPreview] {
    let app = Self.getApp()
    guard let path = getDylibPath(dylibName: "Snapshotting") else {
      NSLog("Snapshotting dylib not found, ensure it is a dependency of your test target.")
      preconditionFailure("Snapshotting dylib not found")
    }

    var launchEnvironment = app.launchEnvironment
    launchEnvironment["EMERGE_IS_RUNNING_FOR_SNAPSHOTS"] = "1"
    launchEnvironment["DYLD_INSERT_LIBRARIES"] = path

    if let previews = Self.snapshotPreviews() {
      if let jsonData = try? JSONSerialization.data(withJSONObject: previews, options: []) {
        launchEnvironment["SNAPSHOT_PREVIEWS"] = String(data: jsonData, encoding: .utf8)
      }
    }

    if let excludedPreviews = Self.excludedSnapshotPreviews() {
      if let jsonData = try? JSONSerialization.data(withJSONObject: excludedPreviews, options: []) {
        launchEnvironment["EXCLUDED_SNAPSHOT_PREVIEWS"] = String(data: jsonData, encoding: .utf8)
      }
    }

    app.launchEnvironment = launchEnvironment
    app.launch()

    guard let url = URL(string: "http://localhost:38824/file") else {
      preconditionFailure("Invalid URL")
    }

    var resultPath: String?
    let request = URLRequest(url: url)
    let group = DispatchGroup()
    group.enter()
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      if let data = data, let stringData = String(data: data, encoding: .utf8) {
        resultPath = stringData
      }
      group.leave()
    }
    task.resume()
    guard group.wait(timeout: .now().advanced(by: .seconds(25))) == .success else {
      preconditionFailure("test timed out")
    }
    guard let resultPath else {
      preconditionFailure("No result path found")
    }
    print("Image can be found in \(resultPath)")
    let metadataUrl = URL(fileURLWithPath: resultPath).appendingPathComponent("metadata.json")
    let data = try! Data(contentsOf: metadataUrl)
    let json = try! JSONSerialization.jsonObject(with: data) as! [[String: Any]]
    return json.map { obj in
      let preview = DiscoveredPreview(typeName: obj["typeName"] as! String,
                                      displayName: obj["displayName"] as? String,
                                      devices: obj["devices"] as! [String],
                                      orientations: obj["orientations"] as! [String],
                                      numberOfPreviews: (obj["numPreviews"] as! NSNumber).intValue)
      return preview
    }
  }

  override func testPreview(_ preview: DiscoveredPreviewAndIndex) {
    let typeName = preview.preview.typeName
    let previewId = preview.index
    let expectation = self.expectation(description: "Waiting for network response")
    guard let url = URL(string: "http://localhost:38824/display/\(typeName)/\(previewId)") else {
      XCTFail("Invalid URL")
      return
    }

    let request = URLRequest(url: url)
    var resultData: Data?
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      resultData = data
      expectation.fulfill()
    }
    task.resume()

    waitForExpectations(timeout: 5) { error in
      if let error = error {
        XCTFail("Test timed out with error: \(error)")
      }
    }

    guard let resultData else {
      XCTFail("Missing result")
      return
    }
    do {
      if let jsonResult = try JSONSerialization.jsonObject(with: resultData, options: []) as? [String: Any] {
        if let errorMessage = jsonResult["error"] as? String {
          let exception = NSException(name: NSExceptionName("SnapshotError"), reason: errorMessage, userInfo: nil)
          exception.raise()
        } else if
          let imagePath = jsonResult["imagePath"] as? String,
          let imageData = try? Data(contentsOf: URL(fileURLWithPath: imagePath))
        {
          var displayName = "Rendered Preview"
          if let customDisplayName = jsonResult["displayName"] as? String {
            displayName = customDisplayName
          }
          let attachment = XCTAttachment(uniformTypeIdentifier: "public.png", name: displayName, payload: imageData, userInfo: nil)
          attachment.lifetime = .keepAlways
          add(attachment)
        }
      }
    } catch {
      XCTFail("Failed to parse JSON: \(error)")
    }

    let app = Self.getApp()
    try? app.performAccessibilityAudit(for: auditType()) { [weak self] issue in
      return self?.handle(issue: issue) ?? false
    }
  }
}
