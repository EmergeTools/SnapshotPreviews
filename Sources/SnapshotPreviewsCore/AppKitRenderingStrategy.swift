//
//  AppKitRenderingStrategy.swift
//
//
//  Created by Noah Martin on 8/8/24.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import Foundation
import AppKit
import SwiftUI
import SnapshotSharedModels

class BorderlessWindow: NSWindow {
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing bufferingType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: [.borderless], backing: bufferingType, defer: flag)
        self.isOpaque = false
        self.backgroundColor = NSColor.clear
    }
}

private var _colorScheme: ColorScheme? = nil

public class AppKitRenderingStrategy: RenderingStrategy {

  private let window: NSWindow

  public init() {
    window = BorderlessWindow()
    window.makeKeyAndOrderFront(nil)
  }

  @MainActor public func render(
    preview: SnapshotPreviewsCore.Preview,
    completion: @escaping (SnapshotResult) -> Void)
  {
    var wrappedView = preview.view()
    _colorScheme = nil
    wrappedView = PreferredColorSchemeWrapper {
      AnyView(wrappedView)
    } colorSchemeUpdater: { scheme in
      _colorScheme = scheme
    }
    let vc = AppKitContainer(rootView: wrappedView)
    vc.setupView(layout: preview.layout)
    // Reset the window size to default before adding the new view controller
    window.contentViewController = NSViewController()
    window.setContentSize(AppKitContainer.defaultSize)
    window.contentViewController = vc
    vc.rendered = { [weak window] mode, precision, accessibilityEnabled, appStoreSnapshot in
      DispatchQueue.main.async {
        let image = window?.snapshot()
        completion(
          SnapshotResult(
            image: image != nil ? .success(image!) : .failure(RenderingError.failedRendering(window?.frame.size ?? .zero)),
            precision: precision,
            accessibilityEnabled: accessibilityEnabled,
            accessibilityMarkers: nil,
            colorScheme: _colorScheme,
            appStoreSnapshot: appStoreSnapshot))
      }
    }
  }
}

final class AppKitContainer: NSHostingController<EmergeModifierView>, ScrollExpansionProviding {

  var supportsExpansion: Bool {
    rootView.supportsExpansion
  }
  var heightAnchor: NSLayoutConstraint?
  var previousHeight: CGFloat?

  public var rendered: ((EmergeRenderingMode?, Float?, Bool?, Bool?) -> Void)? {
    didSet { didCall = false }
  }

  static let defaultSize = NSSize(width: 800, height: 400)

  private var didCall = false
  private var widthAnchor: NSLayoutConstraint?

  init<Content: View>(rootView: Content) {
    super.init(rootView: EmergeModifierView(wrapped: rootView))

    if #available(macOS 13.0, *) {
      sizingOptions = .intrinsicContentSize
    }
    view.translatesAutoresizingMaskIntoConstraints = false
  }

  @MainActor required dynamic init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func removeConstraints() {
    heightAnchor?.isActive = false
    widthAnchor?.isActive = false
    heightAnchor = nil
    widthAnchor = nil
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
      let fittingSize = sizeThatFits(in: Self.defaultSize)
      widthAnchor = view.widthAnchor.constraint(equalToConstant: fittingSize.width)
      widthAnchor?.isActive = true
      heightAnchor = view.heightAnchor.constraint(equalToConstant: fittingSize.height)
      heightAnchor?.isActive = true
    }
  }

  private func runCallback() {
    guard !didCall else { return }

    didCall = true
    rendered?(rootView.emergeRenderingMode, rootView.precision, rootView.accessibilityEnabled, rootView.appStoreSnapshot)
  }

  override func updateViewConstraints() {
    super.updateViewConstraints()
    updateScrollViewHeight()
  }

  public func updateScrollViewHeight() {
    guard rendered != nil else {
      runCallback()
      return
    }

    updateHeight {
      runCallback()
    }
  }
}

extension NSWindow {
    func snapshot() -> NSImage? {
        guard let cgImage = CGWindowListCreateImage(.null,
                                                    .optionIncludingWindow,
                                                    CGWindowID(self.windowNumber),
                                                    .bestResolution)
        else {
            return nil
        }

        return NSImage(cgImage: cgImage, size: self.frame.size)
    }
}

#endif
