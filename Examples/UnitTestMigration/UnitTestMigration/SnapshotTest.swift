//
//  SnapshotTest.swift
//  TestAppInstall
//
//  Created by Noah Martin on 9/11/24.
//

import SwiftUI

// Change your unit test from extending from `XCTestCase` to `SnapshotTest`
// to convert snapshot tests running as XCTests into previews.
// Any call to `assertSnapshot` will automatically be added to the previews.
// Note the class containing your tests should also conform to `PreviewProvider`.
@objcMembers
class SnapshotTest: NSObject {

  required override init() { }

  static var previews: some View {
    generatePreviews()
  }

  func assertSnapshot<Value, Format>(
    of value: @autoclosure () throws -> Value,
    as snapshotting: SnapshotType<Value, Format>,
    named name: String? = nil
  ) where Value: SwiftUI.View {
    try! SnapshotTest.collectedViews.append(AnyView(value().previewLayout(snapshotting.layout)))
  }

  func assertSnapshot<Format>(
    of value: @autoclosure () throws -> UIView,
    as snapshotting: SnapshotType<UIView, Format>,
    named name: String? = nil) {
    try! SnapshotTest.collectedViews.append(
      AnyView(
        UIViewWrapper(view: value()).previewLayout(snapshotting.layout)))
  }

  func assertSnapshot<Format>(
    of value: @autoclosure () throws -> UIViewController,
    as snapshotting: SnapshotType<UIViewController, Format>,
    named name: String? = nil) {
    try! SnapshotTest.collectedViews.append(
      AnyView(UIViewControllerWrapper(viewController: value())
        .previewLayout(snapshotting.layout)))
  }

  private static var collectedViews: [AnyView] = []

  private static func generatePreviews() -> some View {
    let testCase = self.init()
    collectedViews.removeAll()
    testCase.runAllTestMethods()
    return ForEach(0..<collectedViews.count, id: \.self) { index in
        collectedViews[index]
    }
  }

  private func runAllTestMethods() {
    var methodCount: UInt32 = 0
    let methodList = class_copyMethodList(object_getClass(self), &methodCount)
    if let methodList {
      for i in 0..<Int(methodCount) {
        let selector = method_getName(methodList[i])
        let methodName = NSStringFromSelector(selector)
        if methodName.hasPrefix("test") {
          perform(selector)
        }
      }
      free(methodList)
    }
  }
}

private struct UIViewWrapper: UIViewRepresentable {

  let view: UIView

  func makeUIView(context: Context) -> UIView {
    return view
  }

  func updateUIView(_ uiView: UIView, context: Context) { }
}

private struct UIViewControllerWrapper: UIViewControllerRepresentable {

  let viewController: UIViewController

  func makeUIViewController(context: Context) -> UIViewController {
    return viewController
  }

  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
}

struct SnapshotType<Value, Format> {
  let precision: Float
  let layout: PreviewLayout
}

extension SnapshotType where Value: UIView, Format == UIImage {
  static var image: SnapshotType {
    return SnapshotType(precision: 1, layout: .sizeThatFits)
  }
}

extension SnapshotType where Value: SwiftUI.View, Format == UIImage {
  static var image: SnapshotType {
    return .image()
  }

  static func image(
    drawHierarchyInKeyWindow: Bool = false,
    precision: Float = 1,
    perceptualPrecision: Float = 1,
    layout: PreviewLayout = .sizeThatFits,
    traits: UITraitCollection = .init()
  ) -> SnapshotType {
    return SnapshotType(precision: precision, layout: layout)
  }
}
