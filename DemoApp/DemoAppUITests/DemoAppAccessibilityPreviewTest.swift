//
//  DemoAppAccessibilityPreviewTest.swift
//  DemoAppUITests
//
//  Created by Noah Martin on 7/14/23.
//

import Foundation
import XCTest
import SnapshottingTests

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
class DemoAppAccessibilityPreviewTest: AccessibilityPreviewTest {

  override func snapshotPreviews() -> [String]? {
    return nil
  }
    
  override func excludedSnapshotPreviews() -> [String]? {
    return nil
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
