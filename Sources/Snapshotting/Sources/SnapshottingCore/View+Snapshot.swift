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
  public func snapshot(layout: PreviewLayout, window: UIWindow, async: Bool, completion: @escaping (UIImage) -> Void) {
    let controller = ExpandingViewController(rootView: self, layout: layout)
    controller._disableSafeArea = true
    let view = controller.view!
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .clear

    let windowRootVC = Self.setupRootVC(subVC: controller)
    window.rootViewController = windowRootVC
    controller.expansionSettled = {
      if async {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
          completion(Self.takeSnapshot(layout: layout, rootVC: windowRootVC, controller: controller))
        }
      } else {
        DispatchQueue.main.async {
          completion(Self.takeSnapshot(layout: layout, rootVC: windowRootVC, controller: controller))
        }
      }
    }
  }

  private static func setupRootVC(subVC: UIViewController) -> UIViewController {
    let windowRootVC = UIViewController()
    windowRootVC.view.bounds = UIScreen.main.bounds
    windowRootVC.view.backgroundColor = .clear
    windowRootVC.view.addSubview(subVC.view)
    windowRootVC.addChild(subVC)
    subVC.didMove(toParent: windowRootVC)

    subVC.view.centerXAnchor.constraint(equalTo: windowRootVC.view.centerXAnchor).isActive = true
    subVC.view.centerYAnchor.constraint(equalTo: windowRootVC.view.centerYAnchor).isActive = true
    subVC.view.widthAnchor.constraint(lessThanOrEqualToConstant: UIScreen.main.bounds.width).isActive = true

    return windowRootVC
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
        controller.view.layer.layerForSnapshot.render(in: ctx)
      }
    case .sizeThatFits:
      targetSize = view.bounds.size
      drawCode = { ctx in
        controller.view.layer.layerForSnapshot.render(in: ctx)
      }
    case .device:
      fallthrough
    default:
      let viewSize = view.bounds.size

      targetSize = CGSize(width: UIScreen.main.bounds.size.width, height: max(viewSize.height, UIScreen.main.bounds.size.height))
      drawCode = { ctx in
        controller.view.layer.layerForSnapshot.render(in: ctx)
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
