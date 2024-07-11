//
//  UIKitRenderingStrategy.swift
//
//
//  Created by Noah Martin on 7/5/24.
//

#if canImport(UIKit) && !os(watchOS) && !os(visionOS) && !os(tvOS)
import Foundation
import UIKit
import SwiftUI

public class UIKitRenderingStrategy: RenderingStrategy {

  public init() {
    let windowScene = UIApplication.shared
      .connectedScenes
      .filter { $0.activationState == .foregroundActive }
      .first

    let window = windowScene != nil ? UIWindow(windowScene: windowScene as! UIWindowScene) : UIWindow()
    window.windowLevel = .statusBar + 1
    window.backgroundColor = UIColor.systemBackground
    window.makeKeyAndVisible()
    self.window = window
  }

  public var windowScene: UIWindowScene? {
    window.windowScene
  }

  private let window: UIWindow

  @MainActor public func render(
    preview: SnapshotPreviewsCore.Preview,
    completion: @escaping (SnapshotResult) -> Void)
  {
    UIView.setAnimationsEnabled(false)
    let view = preview.view()
    let controller = view.makeExpandingView(layout: preview.layout, window: window)
    view.snapshot(
      layout: preview.layout,
      controller: controller,
      window: window,
      async: false) { result in
        completion(result)
      }
  }
}
#endif
