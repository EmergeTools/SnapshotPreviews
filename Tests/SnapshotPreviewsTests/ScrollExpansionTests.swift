//
//  ScrollExpansionTests.swift
//  SnapshotPreviews
//
//  Created by Trevor Elkins on 5/1/25.
//

import UIKit
import XCTest

@testable import SnapshotPreviewsCore

final class ScrollExpansionUIKitTests: XCTestCase {
  func test_expandsWhenNeeded() {
    let vc = makeVC(visible: 300, content: 500)

    vc.updateHeight {}

    XCTAssertEqual(
      vc.heightAnchor?.constant,
      500,
      "Height should increase by diff between content & visible"
    )
    XCTAssertEqual(
      vc.previousHeight,
      300,
      "previousHeight must capture last visible height"
    )
  }

  func test_doesNotExpandWhenNotSupported() {
    let vc = makeVC(visible: 300, content: 500, supportsExpansion: false)

    vc.updateHeight {}

    XCTAssertEqual(
      vc.heightAnchor?.constant,
      300,
      "Constraint must stay unchanged when expansion is off"
    )
    XCTAssertNil(
      vc.previousHeight,
      "previousHeight should remain nil when no expansion happens"
    )
  }

  func test_doesNotExpandAgainIfAlreadyExpanded() {
    let vc = makeVC(visible: 300, content: 500)

    vc.updateHeight {}
    vc.updateHeight {}  // second call — should be a no-op

    XCTAssertEqual(
      vc.heightAnchor?.constant,
      500,
      "Second invocation must not change the constant"
    )
  }

  private func makeVC(
    visible: CGFloat,
    content: CGFloat,
    supportsExpansion: Bool = true
  ) -> ExpandableVC {
    let vc = ExpandableVC(
      visible: visible,
      content: content,
      initialConstant: visible
    )
    vc.supportsExpansion = supportsExpansion
    return vc
  }
}

private final class ExpandableVC: UIViewController, ScrollExpansionProviding {

  var previousHeight: CGFloat?
  var supportsExpansion: Bool = true

  private(set) var heightConstraint: NSLayoutConstraint?
  var heightAnchor: NSLayoutConstraint? { heightConstraint }

  init(
    visible: CGFloat,
    content: CGFloat,
    initialConstant: CGFloat? = 100
  ) {
    super.init(nibName: nil, bundle: nil)

    let scroll = UIScrollView()
    scroll.contentSize = CGSize(width: 320, height: content)
    scroll.frame = CGRect(x: 0, y: 0, width: 320, height: visible)
    scroll.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scroll)
    NSLayoutConstraint.activate([
      scroll.topAnchor.constraint(equalTo: view.topAnchor),
      scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])

    if let constant = initialConstant {
      heightConstraint = view.heightAnchor.constraint(equalToConstant: constant)
      heightConstraint?.isActive = true
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
