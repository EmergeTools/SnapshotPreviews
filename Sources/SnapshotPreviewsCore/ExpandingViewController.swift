//
//  ExpandingViewController.swift
//  TestAppSwiftUI
//
//  Created by Noah Martin on 6/30/23.
//

import Foundation
import UIKit
import SwiftUI

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

let modifierFinderClass = (NSClassFromString("EmergeModifierFinder") as? NSObject.Type)?.init()
let finder = modifierFinderClass != nil ? Mirror(reflecting: modifierFinderClass!).descendant("finder") as? (any View) -> any View : nil
let modifierState = NSClassFromString("EmergeModifierState") as? NSObject.Type
let stateMirror = modifierState != nil ? Mirror(
  reflecting: modifierState!
    .perform(NSSelectorFromString("shared"))
    .takeUnretainedValue()) : nil

public final class ExpandingViewController: UIHostingController<AnyView> {

  private var didCall = false
  private var previousHeight: CGFloat?

  private var heightAnchor: NSLayoutConstraint?
  private var widthAnchor: NSLayoutConstraint?
  private var isFixed = false

  var expansionSettled: ((EmergeRenderingMode?, Float?) -> Void)?

  override public init(rootView: AnyView) {
    super.init(rootView: rootView)
  }

  func configure<Content: View>(rootView: Content, layout: PreviewLayout) {
    let newView = finder?(rootView)
    presentedViewController?.dismiss(animated: false)
    self.rootView = AnyView(EmptyView())
    self.view.layoutSubviews()
    self.rootView = newView != nil ? AnyView(newView!) : AnyView(rootView)
    self.view.invalidateIntrinsicContentSize()

    previousHeight = nil
    didCall = false
    widthAnchor?.isActive = false
    heightAnchor?.isActive = false
    switch layout {
    case let .fixed(width: width, height: height):
      widthAnchor = view.widthAnchor.constraint(equalToConstant: width)
      heightAnchor = view.heightAnchor.constraint(equalToConstant: height)
      isFixed = true
    default:
      let fittingSize = view.sizeThatFits(UIScreen.main.bounds.size)
      widthAnchor = view.widthAnchor.constraint(greaterThanOrEqualToConstant: fittingSize.width)
      heightAnchor = view.heightAnchor.constraint(greaterThanOrEqualToConstant: fittingSize.height)
      isFixed = false
    }
    widthAnchor?.isActive = true
    heightAnchor?.isActive = true
  }
  
  @MainActor required dynamic init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func runCallback() {
    guard !didCall else { return }

    didCall = true
    let renderingMode = stateMirror?.descendant("renderingMode") as? EmergeRenderingMode.RawValue
    let emergeRenderingMode = renderingMode != nil ? EmergeRenderingMode(rawValue: renderingMode!) : nil
    expansionSettled?(emergeRenderingMode, stateMirror?.descendant("precision") as? Float)
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.updateScrollViewHeight()
  }

  func updateScrollViewHeight() {
    guard let heightAnchor, !isFixed else {
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
