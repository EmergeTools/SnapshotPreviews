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

  private var windowScene: UIWindowScene? {
    window.windowScene
  }

  private let window: UIWindow

  @MainActor
  public func render(
      preview: SnapshotPreviewsCore.Preview,
      completion: @escaping (SnapshotResult) -> Void
  ) {
      Self.setup()
      let targetOrientation = preview.orientation.toInterfaceOrientation()
      guard windowScene!.interfaceOrientation != targetOrientation else {
          performRender(preview: preview, completion: completion)
          return
      }

      if #available(iOS 16.0, *) {
          windowScene!.requestGeometryUpdate(.iOS(interfaceOrientations: targetOrientation.toInterfaceOrientationMask())) { error in
              NSLog("Rotation error handler: \(error) \(self.windowScene!.interfaceOrientation)")
              completion(SnapshotResult(image: .failure(error), precision: nil, accessibilityEnabled: nil, accessibilityMarkers: nil, colorScheme: nil))
              return
          }
          waitForOrientationChange(targetOrientation: targetOrientation, preview: preview, attempts: 50, completion: completion)
      } else {
          performRender(preview: preview, completion: completion)
      }
  }

  @MainActor private func waitForOrientationChange(
      targetOrientation: UIInterfaceOrientation,
      preview: SnapshotPreviewsCore.Preview,
      attempts: Int,
      completion: @escaping (SnapshotResult) -> Void
  ) {
      guard attempts > 0 else {
          let timeoutError = NSError(domain: "OrientationChangeTimeout", code: 0, userInfo: [NSLocalizedDescriptionKey: "Orientation change timed out"])
          completion(SnapshotResult(image: .failure(timeoutError), precision: nil, accessibilityEnabled: nil, accessibilityMarkers: nil, colorScheme: nil))
          return
      }

      if windowScene!.interfaceOrientation == targetOrientation {
          performRender(preview: preview, completion: completion)
      } else {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
              self?.waitForOrientationChange(targetOrientation: targetOrientation, preview: preview, attempts: attempts - 1, completion: completion)
          }
      }
  }

  @MainActor private func performRender(
    preview: SnapshotPreviewsCore.Preview,
    completion: @escaping (SnapshotResult) -> Void
  ) {
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
