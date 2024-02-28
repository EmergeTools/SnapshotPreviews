//
//  View+Snapshot.swift
//  FindPreviews
//
//  Created by Noah Martin on 12/22/22.
//

#if canImport(UIKit) && !os(visionOS)
import Foundation
import SwiftUI
import UIKit
import AccessibilitySnapshotCore

public enum RenderingError: Error {
  case failedRendering(CGSize)
}

extension View {
  public func snapshot(
    layout: PreviewLayout,
    window: UIWindow,
    async: Bool,
    completion: @escaping (Result<UIImage, RenderingError>, Float?, Bool?) -> Void)
  {
    UIView.setAnimationsEnabled(false)
    let animationDisabledView = self.transaction { transaction in
      transaction.disablesAnimations = true
    }
    let controller = ExpandingViewController(rootView: animationDisabledView)
    controller.setupView(layout: layout)

    let (windowRootVC, containerVC) = Self.setupRootVC(subVC: controller)
    window.rootViewController = windowRootVC
    controller.expansionSettled = { [weak containerVC, weak controller] renderingMode, precision, accessibilityEnabled in
      guard let containerVC, let controller else { return }

      if async {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
          completion(Self.takeSnapshot(layout: layout, renderingMode: renderingMode, rootVC: containerVC, targetView: controller.view), precision, accessibilityEnabled)
        }
      } else {
        DispatchQueue.main.async {
          if let accessibilityEnabled, accessibilityEnabled {
            let containedView: UIView
            switch layout {
            case .device:
              containedView = containerVC.view
            default:
              containedView = controller.view
            }
            let mode = controller.view.bounds.size.requiresCoreAnimationSnapshot ? AccessibilitySnapshotView.ViewRenderingMode.renderLayerInContext : renderingMode?.a11yRenderingMode
            let a11yView = AccessibilitySnapshotView(
              containedView: containedView,
              viewRenderingMode: mode ?? .drawHierarchyInRect,
              activationPointDisplayMode: .never,
              showUserInputLabels: true)

            a11yView.center = window.center
            window.addSubview(a11yView)

            try? a11yView.parseAccessibility(useMonochromeSnapshot: false)
            a11yView.sizeToFit()
            let result = Self.takeSnapshot(layout: .sizeThatFits, renderingMode: renderingMode, rootVC: containerVC, targetView: a11yView)
            a11yView.removeFromSuperview()
            completion(result, precision, accessibilityEnabled)
          } else {
            completion(Self.takeSnapshot(layout: layout, renderingMode: renderingMode, rootVC: containerVC, targetView: controller.view), precision, accessibilityEnabled)
          }
        }
      }
    }
  }

  private static func setupRootVC(subVC: UIViewController) -> (UIViewController, UIViewController) {
    let windowRootVC = UIViewController()
    windowRootVC.view.bounds = UIScreen.main.bounds
    windowRootVC.view.backgroundColor = .clear

    let containerVC = UIViewController()
    containerVC.view.backgroundColor = .clear
    containerVC.view.translatesAutoresizingMaskIntoConstraints = false
    windowRootVC.view.addSubview(containerVC.view)
    windowRootVC.addChild(containerVC)
    containerVC.didMove(toParent: windowRootVC)
    containerVC.view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
    containerVC.view.heightAnchor.constraint(greaterThanOrEqualToConstant: UIScreen.main.bounds.height).isActive = true
    containerVC.view.centerXAnchor.constraint(equalTo: windowRootVC.view.centerXAnchor).isActive = true
    containerVC.view.centerYAnchor.constraint(equalTo: windowRootVC.view.centerYAnchor).isActive = true

    containerVC.view.addSubview(subVC.view)
    containerVC.addChild(subVC)
    subVC.didMove(toParent: containerVC)

    subVC.view.centerXAnchor.constraint(equalTo: containerVC.view.centerXAnchor).isActive = true
    subVC.view.centerYAnchor.constraint(equalTo: containerVC.view.centerYAnchor).isActive = true
    subVC.view.widthAnchor.constraint(lessThanOrEqualToConstant: UIScreen.main.bounds.width).isActive = true
    containerVC.view.heightAnchor.constraint(greaterThanOrEqualTo: subVC.view.heightAnchor, multiplier: 1).isActive = true

    return (windowRootVC, containerVC)
  }

  private static func takeSnapshot(
    layout: PreviewLayout,
    renderingMode: EmergeRenderingMode?,
    rootVC: UIViewController,
    targetView: UIView) -> Result<UIImage, RenderingError>
  {
    let view = targetView
    let drawCode: (CGContext) -> Void

    CATransaction.commit()

    let targetSize: CGSize
    var success = false
    switch layout {
    case .fixed(width: let width, height: let height):
      targetSize = CGSize(width: width, height: height)
      drawCode = { ctx in
        success = view.render(size: targetSize, mode: renderingMode, context: ctx)
      }
    case .sizeThatFits:
      targetSize = view.bounds.size
      drawCode = { ctx in
        success = view.render(size: targetSize, mode: renderingMode, context: ctx)
      }
    case .device:
      fallthrough
    default:
      let viewSize = view.bounds.size

      targetSize = CGSize(width: UIScreen.main.bounds.size.width, height: max(viewSize.height, UIScreen.main.bounds.size.height))
      drawCode = { ctx in
        success = rootVC.view.render(size: targetSize, mode: renderingMode, context: ctx)
      }
    }
    let renderer = UIGraphicsImageRenderer(size: targetSize)
    let image = renderer.image { context in
      drawCode(context.cgContext)
    }
    if !success {
      return .failure(RenderingError.failedRendering(targetSize))
    }
    return .success(image)
  }
}

extension CGSize {
  var requiresCoreAnimationSnapshot: Bool {
    height >= UIScreen.main.bounds.size.height * 2
  }
}

extension UIView {
  func render(size: CGSize, mode: EmergeRenderingMode?, context: CGContext) -> Bool {
    switch mode {
    case .coreAnimation:
      layer.layerForSnapshot.render(in: context)
      return true
    case .uiView:
      return drawHierarchy(in: CGRect(origin: .zero, size: size), afterScreenUpdates: true)
    case .none:
      if !size.requiresCoreAnimationSnapshot {
        return drawHierarchy(in: CGRect(origin: .zero, size: size), afterScreenUpdates: true)
      } else {
        layer.layerForSnapshot.render(in: context)
        return true
      }
    }
  }
}

extension EmergeRenderingMode {
  var a11yRenderingMode: AccessibilitySnapshotView.ViewRenderingMode {
    switch self {
    case .coreAnimation:
      return .renderLayerInContext
    case .uiView:
      return .drawHierarchyInRect
    }
  }
}

extension CALayer {

  var layerForSnapshot: Self {
    guard !hasMapView else {
      return self
    }

    return presentation() ?? self
  }

  var hasMapView: Bool {
    if type(of: self).description() == "VKMapView" {
      return true
    }
    for s in sublayers ?? [] {
      if s.hasMapView {
        return true
      }
    }
    return false
  }
}
#endif
