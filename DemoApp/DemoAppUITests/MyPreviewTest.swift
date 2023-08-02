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
}
