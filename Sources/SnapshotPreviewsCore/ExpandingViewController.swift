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

let modifierFinderClass = (NSClassFromString("EmergeModifierFinder") as? NSObject.Type)?.init()
let finder = modifierFinderClass != nil ? Mirror(reflecting: modifierFinderClass!).descendant("finder") as? (any View) -> any View : nil
let modifierState = NSClassFromString("EmergeModifierState") as? NSObject.Type
let stateMirror = modifierState != nil ? Mirror(
  reflecting: modifierState!
    .perform(NSSelectorFromString("shared"))
    .takeUnretainedValue()) : nil

#if canImport(UIKit) && !os(visionOS)

extension UIScrollView {
  var visibleContentHeight: CGFloat {
    frame.height - (adjustedContentInset.top + adjustedContentInset.bottom)
  }
}

extension UIView {
  var firstScrollView: UIScrollView? {
    var subviews = subviews
    while !subviews.isEmpty {
      let subview = subviews.removeFirst()
      // Don’t expand UITextView, it can cause flakes
      guard !(subview is UITextView) else {
        continue
      }

      subviews.append(contentsOf: subview.subviews)
      if let scrollView = subview as? UIScrollView {
        return scrollView
      }
    }
    return nil
  }
}

public final class ExpandingViewController: UIHostingController<AnyView> {

  private var didCall = false
  private var previousHeight: CGFloat?

  private var heightAnchor: NSLayoutConstraint?
  private var widthAnchor: NSLayoutConstraint?

  public var expansionSettled: ((EmergeRenderingMode?, Float?, Bool?) -> Void)? {
    didSet { didCall = false }
  }

  init<Content: View>(rootView: Content) {
    let newView = finder?(rootView)
    super.init(rootView: newView != nil ? AnyView(newView!) : AnyView(rootView))

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
    let renderingMode = stateMirror?.descendant("renderingMode") as? EmergeRenderingMode.RawValue
    let emergeRenderingMode = renderingMode != nil ? EmergeRenderingMode(rawValue: renderingMode!) : nil
    let accessibilityEnabled = stateMirror?.descendant("accessibilityEnabled") as? Bool
    expansionSettled?(emergeRenderingMode, stateMirror?.descendant("precision") as? Float, accessibilityEnabled)
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.updateScrollViewHeight()
  }

  public func updateScrollViewHeight() {
    // If heightAnchor isn't set, this was a fixed size and we don't expand the scroll view
    guard let heightAnchor else {
      runCallback()
      return
    }

    let supportsExpansion = stateMirror?.descendant("expansionPreference") as? Bool ?? true
    let scrollView = view.firstScrollView
    if let scrollView, supportsExpansion {
      let diff = Int(scrollView.contentSize.height - scrollView.visibleContentHeight)
      if abs(diff) > 0 {
        if previousHeight != nil || diff > 0 {
          if let previousHeight {
            // Check if expansion isn't working and we should give up.
            // Could happen if the view is constrained to not grow, such as a half sheet
            guard abs(previousHeight - scrollView.visibleContentHeight) >= 1 else {
              runCallback()
              return
            }
          }
          previousHeight = scrollView.visibleContentHeight
          heightAnchor.constant += CGFloat(diff)
        } else {
          runCallback()
        }
      } else {
        runCallback()
      }
    } else {
      runCallback()
    }
  }

}
#endif
