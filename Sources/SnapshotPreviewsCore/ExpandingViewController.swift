//
//  ExpandingViewController.swift
//  TestAppSwiftUI
//
//  Created by Noah Martin on 6/30/23.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif
import SwiftUI
import SnapshotSharedModels

#if canImport(UIKit) && !os(visionOS) && !os(watchOS) && !os(tvOS)

public final class ExpandingViewController: UIHostingController<EmergeModifierView>, ScrollExpansionProviding {

  var supportsExpansion: Bool {
    rootView.supportsExpansion
  }

  private var didCall = false
  var previousHeight: CGFloat?

  var heightAnchor: NSLayoutConstraint?
  private var widthAnchor: NSLayoutConstraint?

  public var expansionSettled: ((EmergeRenderingMode?, Float?, Bool?) -> Void)? {
    didSet { didCall = false }
  }

  init<Content: View>(rootView: Content) {
    super.init(rootView: EmergeModifierView(wrapped: rootView))

    if #available(iOS 16, *) {
      sizingOptions = .intrinsicContentSize
    }
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .clear
  }

  @MainActor required dynamic init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func removeConstraints() {
    heightAnchor?.isActive = false
    widthAnchor?.isActive = false
    heightAnchor = nil
    widthAnchor = nil
    previousHeight = nil
  }

  public func setupView(layout: PreviewLayout) {
    removeConstraints()
    switch layout {
    case let .fixed(width: width, height: height):
      widthAnchor = view.widthAnchor.constraint(equalToConstant: width)
      widthAnchor?.isActive = true
      heightAnchor = view.heightAnchor.constraint(equalToConstant: height)
      heightAnchor?.isActive = true
    default:
      let fittingSize = sizeThatFits(in: UIScreen.main.bounds.size)
      widthAnchor = view.widthAnchor.constraint(greaterThanOrEqualToConstant: fittingSize.width)
      widthAnchor?.isActive = true
      heightAnchor = view.heightAnchor.constraint(greaterThanOrEqualToConstant: fittingSize.height)
      heightAnchor?.isActive = true
    }
  }

  private func runCallback() {
    guard !didCall else { return }

    didCall = true
    expansionSettled?(rootView.emergeRenderingMode, rootView.precision, rootView.accessibilityEnabled)
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    // Kick off in next run loop cycle to let the layout pass complete first
    DispatchQueue.main.async {
      self.updateScrollViewHeight()
    }
  }

  public func updateScrollViewHeight() {
    guard expansionSettled != nil else {
      runCallback()
      return
    }

    updateHeight {
      runCallback()
    }
  }

}
#endif
