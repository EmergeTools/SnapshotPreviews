//
//  SnapshotTest.swift
//
//
//  Created by Noah Martin on 8/9/24.
//

import Foundation
@_implementationOnly import SnapshotPreviewsCore
@_exported import enum SwiftUI.ColorScheme
import XCTest

extension ColorScheme {
  var stringValue: String {
    switch self {
    case .light:
      return "light"
    case .dark:
      return "dark"
    @unknown default:
      return "unknown"
    }
  }
}

/// A test class for generating snapshots of Xcode previews.
///
/// This class is designed to discover SwiftUI previews, render them, and generate snapshot images for testing purposes.
/// It provides mechanisms for filtering previews and supports different rendering strategies based on the platform.
open class SnapshotTest: PreviewBaseTest, PreviewFilters {
  
  /// Returns an optional array of preview names to be included in the snapshot testing. This also supports Regex format.
  ///
  /// Override this method to specify which previews should be included in the snapshot test.
  /// - Returns: An optional array of String containing the names of previews to be included.
  open class func snapshotPreviews() -> [String]? {
    nil
  }
  
  /// Returns an optional array of preview names to be excluded from the snapshot testing. This also supports Regex format.
  ///
  /// Override this method to specify which previews should be excluded from the snapshot test.
  /// - Returns: An optional array of String containing the names of previews to be excluded.
  open class func excludedSnapshotPreviews() -> [String]? {
    nil
  }

  /// Override to render each preview in multiple color schemes.
  ///
  /// When `nil` (the default), each preview renders once with whatever color scheme
  /// it naturally uses — no override is applied. When set to e.g. `[.light, .dark]`,
  /// each preview renders once per scheme, producing separate snapshot files suffixed
  /// with the scheme name.
  ///
  /// - Returns: An optional array of `ColorScheme` values, or `nil` for no override.
  open class func colorSchemes() -> [ColorScheme]? {
    nil
  }
  
  #if canImport(UIKit) && !os(watchOS) && !os(visionOS) && !os(tvOS)
  open class func setupA11y() -> ((UIViewController, UIWindow, PreviewLayout) -> UIView)? {
    return nil
  }
  #endif

  /// Determines the appropriate rendering strategy based on the current platform and OS version.
  ///
  /// This method selects between UIKit, AppKit, and SwiftUI rendering strategies depending on the available frameworks and OS version.
  /// - Returns: A `RenderingStrategy` object suitable for the current environment.
  #if canImport(UIKit) && !os(watchOS) && !os(visionOS) && !os(tvOS)
  private static func makeRenderingStrategy(a11y: ((UIViewController, UIWindow, PreviewLayout) -> UIView)?) -> RenderingStrategy {
    return UIKitRenderingStrategy(a11yWrapper: a11y)
  }
  #else
  private static func makeRenderingStrategy() -> RenderingStrategy {
    #if canImport(AppKit) && !targetEnvironment(macCatalyst)
      AppKitRenderingStrategy()
    #else
    if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *) {
      SwiftUIRenderingStrategy()
    } else {
      preconditionFailure("Cannot snapshot on this device/os")
    }
    #endif
  }
    #endif
  private static var renderingStrategy: RenderingStrategy? = nil

  static private var previews: [SnapshotPreviewsCore.PreviewType] = []
  
  static private var previewCountForFileId: [String: Int] = [:]
  static private var previewDisplayNameCountByGroup: [String: [String: Int]] = [:]

  static func resolvedFileNameComponent(
    fileId: String?,
    line: Int?,
    previewDisplayName: String?,
    previewIndex: Int,
    duplicateDisplayNameCount: Int
  ) -> String {
    if let previewDisplayName, !previewDisplayName.isEmpty, duplicateDisplayNameCount <= 1 {
      return previewDisplayName
    }

    if let fileId, !fileId.isEmpty, let line {
      return "line-\(line)"
    }

    return String(previewIndex)
  }

  @MainActor
  override class func discoverPreviews() -> [DiscoveredPreview] {
    _ = SnapshotCIExportCoordinator.sharedIfEnabled()

    previews = FindPreviews.findPreviews(included: Self.snapshotPreviews(), excluded: Self.excludedSnapshotPreviews())
    previewCountForFileId = [:]
    previewDisplayNameCountByGroup = [:]

    for previewType in previews {
      if let fileId = previewType.fileID {
        previewCountForFileId[fileId, default: 0] += 1
      }

      let group = previewType.fileID ?? previewType.typeName
      for preview in previewType.previews {
        guard let previewDisplayName = preview.displayName, !previewDisplayName.isEmpty else {
          continue
        }
        previewDisplayNameCountByGroup[group, default: [:]][previewDisplayName, default: 0] += 1
      }
    }

    return previews.map { DiscoveredPreview.from(previewType: $0) }
  }

  /// Tests a specific preview by rendering it and generating a snapshot. Subclasses should NOT override this method.
  ///
  /// This method renders the specified preview using the appropriate rendering strategy,
  /// creates a snapshot image, and attaches it to the test results.
  ///
  /// - Parameter discoveredPreview: A `DiscoveredPreviewAndIndex` object representing the preview to be tested.
  @MainActor
  override func testPreview(_ discoveredPreview: DiscoveredPreviewAndIndex) {
    guard let previewType = Self.previews.first(where: { $0.typeName == discoveredPreview.preview.typeName }) else {
      XCTFail("Preview type not found")
      return
    }

    let preview = previewType.previews[discoveredPreview.index]

    // Lazily create the rendering strategy
    if Self.renderingStrategy == nil {
      #if canImport(UIKit) && !os(watchOS) && !os(visionOS) && !os(tvOS)
      Self.renderingStrategy = Self.makeRenderingStrategy(a11y: Self.setupA11y())
      #else
      Self.renderingStrategy = Self.makeRenderingStrategy()
      #endif
    }
    let strategy = Self.renderingStrategy!

    var typeFileName = previewType.displayName
    if let fileId = previewType.fileID, let lineNumber = previewType.line {
      typeFileName = Self.previewCountForFileId[fileId]! > 1 ? "\(fileId):\(lineNumber)" : fileId
    }

    let schemes = Self.colorSchemes()
    let renderPasses: [(scheme: ColorScheme?, suffix: String)] = if let schemes {
      schemes.map { ($0, "_\($0.stringValue)") }
    } else {
      [(nil, "")]
    }

    defer {
      if schemes != nil {
        applyColorSchemeOverride(nil)
      }
    }

    for pass in renderPasses {
      if let scheme = pass.scheme {
        applyColorSchemeOverride(scheme)
      }

      var result: SnapshotResult? = nil
      let expectation = XCTestExpectation()
      strategy.render(preview: preview) { snapshotResult in
        result = snapshotResult
        expectation.fulfill()
      }
      wait(for: [expectation], timeout: 10)
      guard let result else {
        XCTFail("Did not render")
        continue
      }

      let previewGroup = previewType.fileID ?? previewType.typeName
      let duplicateDisplayNameCount = preview.displayName.flatMap {
        Self.previewDisplayNameCountByGroup[previewGroup]?[$0]
      } ?? 0
      let fileNameComponent = Self.resolvedFileNameComponent(
        fileId: previewType.fileID,
        line: previewType.line,
        previewDisplayName: preview.displayName,
        previewIndex: discoveredPreview.index,
        duplicateDisplayNameCount: duplicateDisplayNameCount
      )
      let baseFileName = "\(typeFileName)_\(fileNameComponent)\(pass.suffix)"
      let colorSchemeValue = pass.scheme?.stringValue ?? result.colorScheme?.stringValue

      let context = SnapshotContext(
        baseFileName: baseFileName,
        testName: name,
        typeName: previewType.typeName,
        typeDisplayName: previewType.displayName,
        fileId: previewType.fileID,
        line: previewType.line,
        previewDisplayName: preview.displayName,
        previewIndex: discoveredPreview.index,
        previewId: preview.previewId,
        orientation: preview.orientation.id,
        declaredDevice: preview.device?.rawValue,
        simulatorDeviceName: ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"],
        simulatorModelIdentifier: ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"],
        precision: result.precision,
        accessibilityEnabled: result.accessibilityEnabled,
        colorScheme: colorSchemeValue,
        appStoreSnapshot: result.appStoreSnapshot)

      if let coordinator = SnapshotCIExportCoordinator.sharedIfEnabled() {
        coordinator.enqueueExport(result: result, context: context)
      } else {
        do {
          let attachment = try XCTAttachment(image: result.image.get())
          attachment.name = baseFileName
          attachment.lifetime = .keepAlways
          add(attachment)
        } catch {
          XCTFail("Error \(error)")
        }
      }
    }
  }
}

// Color scheme override helpers — kept outside the open class to avoid
// @_implementationOnly deserialization issues with private members.

@MainActor
private func applyColorSchemeOverride(_ scheme: ColorScheme?) {
  #if canImport(UIKit) && !os(watchOS)
  let style: UIUserInterfaceStyle
  switch scheme {
  case .light:
    style = .light
  case .dark:
    style = .dark
  case nil:
    style = .unspecified
  @unknown default:
    style = .unspecified
  }
  for scene in UIApplication.shared.connectedScenes {
    guard let windowScene = scene as? UIWindowScene else { continue }
    for window in windowScene.windows {
      window.overrideUserInterfaceStyle = style
    }
  }
  #elseif canImport(AppKit) && !targetEnvironment(macCatalyst)
  switch scheme {
  case .light:
    NSApplication.shared.appearance = NSAppearance(named: .aqua)
  case .dark:
    NSApplication.shared.appearance = NSAppearance(named: .darkAqua)
  case nil:
    NSApplication.shared.appearance = nil
  @unknown default:
    NSApplication.shared.appearance = nil
  }
  #endif
}
