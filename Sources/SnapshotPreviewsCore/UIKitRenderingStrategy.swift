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

  private let window: UIWindow
  private var colorScheme: ColorScheme? = nil

  @MainActor public func render(
    preview: SnapshotPreviewsCore.Preview,
    completion: @escaping (Result<ImageType, Error>, Float?, Bool?, ColorScheme?) -> Void)
  {
    var view = preview.view()
    colorScheme = nil
    view = PreferredColorSchemeWrapper {
      AnyView(view)
    } colorSchemeUpdater: { [weak self] scheme in
      self?.colorScheme = scheme
    }
    let controller = view.makeExpandingView(layout: preview.layout, window: window)
    view.snapshot(
      layout: preview.layout,
      controller: controller,
      window: window,
      async: false) { [weak self] result in
        completion(result.image.mapError { $0 }, result.precision, result.accessibilityEnabled, self?.colorScheme)
      }
  }
}
#endif
