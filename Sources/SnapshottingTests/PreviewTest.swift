//
//  PreviewTest.swift
//  
//
//  Created by Noah Martin on 8/9/24.
//

import Foundation
import SnapshottingTestsObjc
import MachO

open class PreviewTest: EMGPreviewBaseTest {

  open func getApp() -> XCUIApplication {
    XCUIApplication()
  }

  // Override to return a list of previews that should be snapshotted.
  // The default is null, which snapshots all previews.
  // Elements should be the type name of the preview, like "MyModule.MyView_Previews"
  open func snapshotPreviews() -> [String]? {
    nil
  }

  open func excludedSnapshotPreviews() -> [String]? {
    nil
  }

  open var enableAccessibilityAudit: Bool {
    true
  }

  @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
  open func auditType() -> XCUIAccessibilityAuditType { .all }

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

  override public class func discoverPreviews() -> [EMGDiscoveredPreview] {
    let instance = self.create()
    let app = instance.getApp()
    guard let path = getDylibPath(dylibName: "Snapshotting") else {
      NSLog("Snapshotting dylib not found, ensure it is a dependency of your test target.")
      preconditionFailure("Snapshotting dylib not found")
    }

    var launchEnvironment = app.launchEnvironment
    launchEnvironment["EMERGE_IS_RUNNING_FOR_SNAPSHOTS"] = "1"
    launchEnvironment["DYLD_INSERT_LIBRARIES"] = path

    if let previews = instance.snapshotPreviews() {
      if let jsonData = try? JSONSerialization.data(withJSONObject: previews, options: []) {
        launchEnvironment["SNAPSHOT_PREVIEWS"] = String(data: jsonData, encoding: .utf8)
      }
    }

    if let excludedPreviews = instance.excludedSnapshotPreviews() {
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
      let preview = EMGDiscoveredPreview()
      preview.typeName = obj["typeName"] as! String
      preview.displayName = obj["displayName"] as? String
      preview.numberOfPreviews = obj["numPreviews"] as! NSNumber
      return preview
    }
  }

  override public func test(_ preview: EMGPreview) {
    let typeName = preview.preview.typeName
    let previewId = preview.index
    let expectation = self.expectation(description: "Waiting for network response")
    guard let url = URL(string: "http://localhost:38824/display/\(typeName)/\(previewId.intValue)") else {
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

    if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
      if enableAccessibilityAudit {
        let app = getApp()
        try? app.performAccessibilityAudit(for: auditType()) { [weak self] issue in
          return self?.handle(issue: issue) ?? false
        }
      }
    }
  }
}
