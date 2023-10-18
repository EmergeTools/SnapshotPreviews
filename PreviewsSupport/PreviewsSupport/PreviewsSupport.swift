//
//  PreviewsSupport.swift
//  PreviewsSupport
//
//  Created by Noah Martin on 10/18/23.
//

import SwiftUI
import UIKit

public protocol MakeViewProvider {
  var makeView: @MainActor () -> any View { get }
}

public protocol MakeUIViewProvider {
  var makeView: @MainActor () -> UIView { get }
}

public protocol MakeViewControllerProvider {
  var makeViewController: @MainActor () -> UIViewController { get }
}

public struct Testing { }

@available(iOS 17.0, *)
extension UIViewPreviewSource: MakeUIViewProvider { }

@available(iOS 17.0, *)
extension UIViewControllerPreviewSource: MakeViewControllerProvider { }

@available(iOS 17.0, *)
extension ViewPreviewSource: MakeViewProvider { }
