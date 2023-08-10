//
//  View+Snapshot.swift
//  FindPreviews
//
//  Created by Noah Martin on 12/22/22.
//

import Foundation
import SwiftUI
import UIKit

extension View {
  public func snapshot(layout: PreviewLayout, window: UIWindow, async: Bool, completion: @escaping (Result<UIImage, Error>) -> Void) {
    UIView.setAnimationsEnabled(false)
    let animationDisabledView = self.transaction { transaction in
      transaction.disablesAnimations = true
    }
    let controller = ExpandingViewController(rootView: animationDisabledView, layout: layout)
    controller._disableSafeArea = true
    let view = controller.view!
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .clear

    let (windowRootVC, containerVC) = Self.setupRootVC(subVC: controller)
    window.rootViewController = windowRootVC
    controller.expansionSettled = {
      if async {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
          completion(.success(Self.takeSnapshot(layout: layout, rootVC: containerVC, controller: controller)))
        }
      } else {
        DispatchQueue.main.async {
          completion(.success(Self.takeSnapshot(layout: layout, rootVC: containerVC, controller: controller)))
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

  private static func takeSnapshot(layout: PreviewLayout, rootVC: UIViewController, controller: UIViewController) -> UIImage {
    let view = controller.view!
    let drawCode: (CGContext) -> Void

    CATransaction.commit()

    let targetSize: CGSize
    switch layout {
    case .fixed(width: let width, height: let height):
      targetSize = CGSize(width: width, height: height)
      drawCode = { ctx in
        view.layer.layerForSnapshot.render(in: ctx)
      }
    case .sizeThatFits:
      targetSize = view.bounds.size
      drawCode = { ctx in
        view.layer.layerForSnapshot.render(in: ctx)
      }
    case .device:
      fallthrough
    default:
      let viewSize = view.bounds.size

      targetSize = CGSize(width: UIScreen.main.bounds.size.width, height: max(viewSize.height, UIScreen.main.bounds.size.height))
      drawCode = { ctx in
        rootVC.view.layer.layerForSnapshot.render(in: ctx)
      }
    }
    let renderer = UIGraphicsImageRenderer(size: targetSize)
    let image = renderer.image { context in
      drawCode(context.cgContext)
    }
    return image
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
