//
//  ScrollExpansion.swift
//
//
//  Created by Noah Martin on 8/22/24.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

protocol ContentHeightProviding {
  var contentHeight: CGFloat { get }

  var visibleContentHeight: CGFloat { get }
}

protocol FirstScrollViewProviding {
  var firstScrollView: ContentHeightProviding? { get }
}

#if !os(watchOS)
protocol ScrollExpansionProviding: AnyObject, FirstScrollViewProviding {
  var previousHeight: CGFloat? { get set }
  var heightAnchor: NSLayoutConstraint? { get }
  var supportsExpansion: Bool { get }
}

extension ScrollExpansionProviding {
  func updateHeight(_ complete: (() -> Void)) {
    // If heightAnchor isn't set, this was a fixed size and we don't expand the scroll view
    guard let heightAnchor else {
      complete()
      return
    }

    let supportsExpansion = supportsExpansion
    let scrollView = firstScrollView
    if let scrollView, supportsExpansion {
      let diff = Int(scrollView.contentHeight - scrollView.visibleContentHeight)
      if abs(diff) > 0 {
        if previousHeight != nil || diff > 0 {
          if let previousHeight {
            // Check if expansion isn't working and we should give up.
            // Could happen if the view is constrained to not grow, such as a half sheet
            guard abs(previousHeight - scrollView.visibleContentHeight) >= 1 else {
              complete()
              return
            }
          }
          previousHeight = scrollView.visibleContentHeight
          heightAnchor.constant += CGFloat(diff)
        } else {
          complete()
        }
      } else {
        complete()
      }
    } else {
      complete()
    }
  }
}
#endif

#if canImport(UIKit) && !os(visionOS) && !os(watchOS) && !os(tvOS)
extension UIScrollView: ContentHeightProviding {

  var contentHeight: CGFloat {
    contentSize.height
  }

  var visibleContentHeight: CGFloat {
    frame.height - (adjustedContentInset.top + adjustedContentInset.bottom)
  }
}

extension UIView: FirstScrollViewProviding {
  var firstScrollView: ContentHeightProviding? {
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

extension UIViewController: FirstScrollViewProviding {
  var firstScrollView: ContentHeightProviding? {
    view?.firstScrollView
  }
}
#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
extension NSScrollView: ContentHeightProviding {

  var contentHeight: CGFloat {
    documentView?.frame.size.height ?? 0
  }

  var visibleContentHeight: CGFloat {
    frame.height - (contentInsets.top + contentInsets.bottom)
  }
}

extension NSView: FirstScrollViewProviding {
  var firstScrollView: ContentHeightProviding? {
    var subviews = subviews
    while !subviews.isEmpty {
      let subview = subviews.removeFirst()
      subviews.append(contentsOf: subview.subviews)
      // Don’t expand NSTextView, it can cause flakes
      if let scrollView = subview as? NSScrollView, !(scrollView.documentView is NSTextView) {
        return scrollView
      }
    }
    return nil
  }
}

extension NSViewController: FirstScrollViewProviding {
  var firstScrollView: ContentHeightProviding? {
    view.firstScrollView
  }
}
#endif
