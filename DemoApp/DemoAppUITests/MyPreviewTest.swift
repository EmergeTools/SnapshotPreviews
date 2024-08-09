//
//  MultipleTests.swift
//  DemoAppUITests
//
//  Created by Noah Martin on 7/14/23.
//

import Foundation
import XCTest
import SnapshottingTests

class MyPreviewTest: PreviewTest {

  override func snapshotPreviews() -> [String]? {
    return nil
  }
    
  override func excludedSnapshotPreviews() -> [String]? {
    return nil
  }

  override var enableAccessibilityAudit: Bool {
    true
  }

  @available(iOS 17.0, *)
  override func auditType() -> XCUIAccessibilityAuditType {
    return .all
  }

  @available(iOS 17.0, *)
  override func handle(issue: XCUIAccessibilityAuditIssue) -> Bool {
    return false
  }
}
