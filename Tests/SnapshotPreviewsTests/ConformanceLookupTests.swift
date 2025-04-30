import SwiftUI
import XCTest

@testable import SnapshotPreviewsCore

struct TestView: View {
  var body: some View {
    Text("Hello world!")
  }
}

#Preview {
  TestView()
}

final class ConformanceLookupTests: XCTestCase {
  func testExample() throws {
    let types = ConformanceLookup.getPreviewTypes()
    XCTAssertEqual(types.count, 1)

    let firstType = types.first!
    XCTAssertEqual(
      "SnapshotPreviewsTests.$s21SnapshotPreviewsTests0033ConformanceLookupTestsswift_DbGHjfMX11_0_33_AB2146FE95919420F4A1C0A89BE8EA36Ll7PreviewfMf_15PreviewRegistryfMu_",
      firstType.name
    )
    XCTAssertEqual("PreviewRegistry", firstType.proto)
  }
}
