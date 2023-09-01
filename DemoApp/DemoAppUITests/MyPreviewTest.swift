//
//  MultipleTests.swift
//  DemoAppUITests
//
//  Created by Noah Martin on 7/14/23.
//

import Foundation
import XCTest
import Snapshotting
import SnapshottingTests

class MyPreviewTest: PreviewTest {

  override func getApp() -> XCUIApplication {
    return XCUIApplication()
  }

  override func snapshotPreviews() -> [String]? {
    return nil
  }

  override func enableAccessibilityAudit() -> Bool {
    true
  }

  @available(iOS 17.0, *)
  override func auditType() -> XCUIAccessibilityAuditType {
    return .all
  }

  @available(iOS 17.0, *)
  override func handle(_ issue: XCUIAccessibilityAuditIssue) -> Bool {
    return false
  }
}
