import XCTest

@testable import SnapshotPreviewsCore

final class ConformanceLookupTests: XCTestCase {
  func testGetPreviewTypes() throws {
    let types = ConformanceLookup.getPreviewTypes()
    XCTAssertEqual(types.count, 1)

    let firstType = types.first!
    XCTAssertEqual(
      "SnapshotPreviewsTests.$s21SnapshotPreviewsTests0019TestViewswift_DJEEdfMX15_0_33_B5E96601318DE1EC85533DD88EB53190Ll7PreviewfMf_15PreviewRegistryfMu_",
      firstType.name
    )
    XCTAssertEqual("PreviewRegistry", firstType.proto)
  }
}
