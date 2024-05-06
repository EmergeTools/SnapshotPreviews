//
//  PreviewsSupport.swift
//  PreviewsSupport
//
//  Created by Noah Martin on 10/18/23.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public protocol MakeViewProvider {
  var makeView: @MainActor () -> any View { get }
}

#if canImport(UIKit)
public protocol MakeUIViewProvider {
  var makeView: @MainActor () -> UIView { get }
}

public protocol MakeViewControllerProvider {
  var makeViewController: @MainActor () -> UIViewController { get }
}

@available(iOS 17.0, macOS 14.0, *)
@_spi(Private)
extension UIViewPreviewSource: MakeUIViewProvider { }

@available(iOS 17.0, macOS 14.0, *)
@_spi(Private)
extension UIViewControllerPreviewSource: MakeViewControllerProvider { }
#endif

@available(iOS 17.0, macOS 14.0, *)
@_spi(Private)
extension ViewPreviewSource: MakeViewProvider { }
