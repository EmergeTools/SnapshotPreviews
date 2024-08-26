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

  // Snapshots have an overall time limit of 10s, so limit this part to 5s
  private let HeightExpansionTimeLimitInSeconds: Double = 5

  private var didCall = false
  var previousHeight: CGFloat?

  var heightAnchor: NSLayoutConstraint?
  private var widthAnchor: NSLayoutConstraint?

  private var startTime: Date?
  private var timer: Timer?
  private var elapsedTime: TimeInterval = 0

  public var expansionSettled: ((EmergeRenderingMode?, Float?, Bool?, Error?) -> Void)? {
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

  private func runCallback(_ error: Error? = nil) {
    guard !didCall else { return }

    didCall = true
    expansionSettled?(rootView.emergeRenderingMode, rootView.precision, rootView.accessibilityEnabled, error)
    stopAndResetTimer()
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    DispatchQueue.main.async {
      self.updateScrollViewHeight()
    }
  }

  public func updateScrollViewHeight() {
    let scrollView = view.firstScrollView


//    WILL MOVE TO SCROLL EXPANSION, have to test post rebase
    // Timeout limit
    if timer == nil {
      startTimer()
    } else if elapsedTime >= HeightExpansionTimeLimitInSeconds {
      let timeoutError = RenderingError.expandingViewTimeout(CGSize(width: UIScreen.main.bounds.size.width, height: scrollView?.visibleContentHeight ?? -1))
      NSLog("ExpandingViewController: Expanding scroll view timed out")

      // Setting anchors back to full
      let fittingSize = sizeThatFits(in: UIScreen.main.bounds.size)
      heightAnchor = view.heightAnchor.constraint(greaterThanOrEqualToConstant: fittingSize.height)
      widthAnchor = view.heightAnchor.constraint(greaterThanOrEqualToConstant: fittingSize.width)
      runCallback(timeoutError)
      return
    }

    guard expansionSettled != nil else {
      runCallback()
      return
    }

    updateHeight {
      runCallback()
    }
  }

//  MARK: - Timer

  func startTimer() {
      if self.timer == nil {
          self.startTime = Date()
          self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
              guard let self else {
                  return
              }
              if let start = self.startTime {
                  self.elapsedTime = Date().timeIntervalSince(start)
                  if self.elapsedTime >= HeightExpansionTimeLimitInSeconds {
                      let scrollView = self.view.firstScrollView
                      let timeoutError = RenderingError.expandingViewTimeout(CGSize(width: UIScreen.main.bounds.size.width, height: scrollView?.visibleContentHeight ?? -1))
                      NSLog("ExpandingViewController: Expanding Scroll View timed out. Current height is \(scrollView?.visibleContentHeight ?? -1)")

                      // Setting anchors back to full
                      let fittingSize = self.sizeThatFits(in: UIScreen.main.bounds.size)
                      self.heightAnchor = self.view.heightAnchor.constraint(greaterThanOrEqualToConstant: fittingSize.height)
                      self.widthAnchor = self.view.heightAnchor.constraint(greaterThanOrEqualToConstant: fittingSize.width)
                      self.runCallback(timeoutError)
                  }
              }
          }
          print("Timer scheduled")
      } else {
          print("Timer already exists")
      }
  }

  func stopAndResetTimer() {
      timer?.invalidate()
      timer = nil
      startTime = nil
      elapsedTime = 0
  }

}
#endif
