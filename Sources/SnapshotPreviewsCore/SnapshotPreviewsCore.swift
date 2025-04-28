import SwiftUI
import PreviewsSupport

public struct Preview: Identifiable {
  init<P: SwiftUI.PreviewProvider>(preview: _Preview, type: P.Type, uniqueName: String) {
    previewId = "\(preview.id)"
    index = preview.id
    orientation = preview.interfaceOrientation
    displayName = preview.displayName
    device = preview.device
    layout = preview.layout
    _view = {
      ViewSelectorTree(SnapshotViewModel(index: preview.id)) {
        P.previews
      }
    }
    self.uniqueName = uniqueName
  }

  @available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
  init?(preview: DeveloperToolsSupport.Preview, uniqueName: String) {
    previewId = "0"
    var orientation: InterfaceOrientation = .portrait
    device = nil
    index = 0
    let preview = Mirror(reflecting: preview)
    let traits = preview.descendant("traits")! as! [Any]
    var layout = PreviewLayout.device
    for t in traits {
      if let value = Mirror(reflecting: t).descendant("value") {
        if let value = value as? PreviewLayout {
          layout = value
        } else if String(describing: value).hasSuffix(".portraitUpsideDown") {
          orientation = .portraitUpsideDown
        } else if String(describing: value).hasSuffix(".landscapeLeft") {
          orientation = .landscapeLeft
        } else if String(describing: value).hasSuffix(".landscapeRight") {
          orientation = .landscapeRight
        }
      }
    }
    self.orientation = orientation
    self.layout = layout
    displayName = preview.descendant("displayName") as? String
    let source = preview.descendant("source")!
    let _view: @MainActor () -> any View
    if let source = source as? MakeViewProvider {
      _view = {
        return source.makeView()
      }
    } else {
      #if canImport(UIKit) && !os(watchOS)
      if let source = source as? MakeUIViewProvider {
        _view = {
          return UIViewWrapper(source.makeView)
        }
      } else if let source = source as? MakeViewControllerProvider {
        _view = {
          return UIViewControllerWrapper(source.makeViewController)
        }
      } else {
        return nil
      }
      #else
      return nil
      #endif
    }

    self._view = _view
    self.uniqueName = uniqueName
  }

  public let id = UUID()
  public let previewId: String
  public let orientation: InterfaceOrientation
  public let displayName: String?
  public let index: Int
  public let device: PreviewDevice?
  public let layout: PreviewLayout
  public let uniqueName: String
  private let _view: @MainActor () -> any View
  @MainActor public func view() -> any View {
    _view()
  }
}

public struct PreviewType: Hashable, Identifiable {
  fileprivate init(previewTypeInfo: PreviewTypeInfo, previews: [Preview]) {
    self.typeName = previewTypeInfo.name
    self.fileID = previewTypeInfo.fileID
    self.line = previewTypeInfo.line
    self.previews = previews
    self.platform = previewTypeInfo.platform
  }

  public var module: String {
    String(typeName.split(separator: ".").first!)
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(typeName)
  }

  public static func ==(lhs: Self, rhs: Self) -> Bool {
    lhs.typeName == rhs.typeName
  }

  public var displayName: String {
    if let fileID = fileID {
      return String(fileID.split(separator: "/").last!.split(separator: ".").first!).splittingHumanReadableName.joined(separator: " ")
    }
    let withoutModule = typeName
      .split(separator: ".")
      .dropFirst()
      .joined(separator: ".")
    let components = withoutModule.splittingHumanReadableName
    if components.last == "Previews" {
      return components.dropLast().joined(separator: " ")
    }
    return components.joined(separator: " ")
  }

  public let id = UUID()
  public let fileID: String?
  public let line: Int?
  public let typeName: String
  public var previews: [Preview]
  public let platform: PreviewPlatform?
}

private struct PreviewTypeInfo {
  let name: String
  let fileID: String?
  let line: Int?
  let previews: [InternalPreview]
  let platform: PreviewPlatform?
}

private enum InternalPreview {
  case previewProvider(_Preview, any SwiftUI.PreviewProvider.Type)
  // Can't use DeveloperToolsSupport.Preview here because it's not available before iOS 17
  case previewRegistry(Any)
  
  func getPreviewId() -> String {
    switch self {
    case .previewProvider(let internalPreview, _):
      "\(internalPreview.id)"
    case .previewRegistry(_):
      "0"
    }
  }
  
  func getDisplayName() -> String? {
    switch self {
    case .previewProvider(let internalPreview, _):
      internalPreview.displayName
    case .previewRegistry(let internalPreview):
      Mirror(reflecting: internalPreview).descendant("displayName") as? String
    }
  }
}

// The enum provides a namespace
public enum FindPreviews {
  @available(iOS 16.0, macOS 13.0, tvOS 16.0, *)
  private static func shouldInclude(name: String, excludedPreviewsSet: Set<String>?, previewsSet: Set<String>?) -> Bool {
    if let excludedPreviewsSet {
      for excludedPreview in excludedPreviewsSet {
        do {
          let regex = try Regex(excludedPreview)
          if name.firstMatch(of: regex) != nil {
            return false
          }
        } catch {
          print("Error trying to unwrap regex for excludedSnapshotPreview (\(excludedPreview)): \(error)")
        }
      }
    }

    guard let previewsSet else { return true }
    for preview in previewsSet {
      do {
        let regex = try Regex(preview)
        if name.firstMatch(of: regex) != nil {
          return true
        }
      } catch {
        print("Error trying to unwrap regex for snapshotPreview (\(preview)): \(error)")
      }
    }

    return false
  }

  @MainActor
  public static func findPreviews(included: [String]?, excluded: [String]?) -> [PreviewType] {
    let previewsSet = included.map { Set($0) }
    let excludedPreviewsSet = excluded.map { Set($0) }

    let previewTypes = findPreviews { name, proto in
      guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, *) else { return true }
      guard proto == "PreviewProvider" else { return true }

      return shouldInclude(name: name, excludedPreviewsSet: excludedPreviewsSet, previewsSet: previewsSet)
    }
    return previewTypes.compactMap { preview -> PreviewType? in
      if let fileId = preview.fileID, #available(iOS 16.0, macOS 13.0, tvOS 16.0, *) {
        var name = fileId
        if let displayName = preview.previews[0].displayName {
          name = "\(fileId):\(displayName)"
        }
        if !shouldInclude(name: name, excludedPreviewsSet: excludedPreviewsSet, previewsSet: previewsSet) {
          return nil
        }
      }
      return preview
    }
  }

  @MainActor
  public static func findPreviews(
    shouldInclude: (String, String) -> Bool = { _, _ in true },
    willAccess: (String) -> Void = { _ in }) -> [PreviewType]
  {
    let rawPreviewTypes = getPreviewTypes()
      .filter { shouldInclude($0.name, $0.proto) }
    
    let previewTypeInfos = rawPreviewTypes.compactMap { rawType -> PreviewTypeInfo? in
      willAccess(rawType.name)
      switch rawType.proto {
      case "PreviewProvider":
        let previewProvider = unsafeBitCast(rawType.accessor(), to: Any.Type.self) as! any PreviewProvider.Type
        return PreviewTypeInfo(
          name: rawType.name,
          fileID: nil,
          line: nil,
          previews: previewProvider._allPreviews.map { .previewProvider($0, previewProvider.self) },
          platform: previewProvider.platform
        )
      case "PreviewRegistry":
        if #available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *) {
          let previewRegistry = unsafeBitCast(rawType.accessor(), to: Any.Type.self) as! any PreviewRegistry.Type
          guard let internalPreview = try? previewRegistry.makePreview() else {
            return nil
          }
          return PreviewTypeInfo(
            name: rawType.name,
            fileID: previewRegistry.fileID,
            line: previewRegistry.line,
            previews: [ .previewRegistry(internalPreview) ],
            platform: nil
          )
        }
        return nil
      default:
        return nil
      }
    }
    
    let previewCountForId = calculateIdToPreviewCount(previewTypeInfos)
    
    return generateFinalPreviewTypes(previewTypeInfos: previewTypeInfos, previewCountForId: previewCountForId)
  }
  
  private static func calculateIdToPreviewCount(_ previewTypeInfos: [PreviewTypeInfo]) -> [String: Int] {
    var previewCountForId: [String: Int] = [:]
    for previewTypeInfo in previewTypeInfos {
      for preview in previewTypeInfo.previews {
        let possibleId = possibleUniqueIdForPreview(preview, previewTypeInfo)
        previewCountForId[possibleId, default: 0] += 1
      }
    }
    return previewCountForId
  }
  
  private static func generateFinalPreviewTypes(previewTypeInfos: [PreviewTypeInfo], previewCountForId: [String: Int]) -> [PreviewType] {
    previewTypeInfos.map { previewTypeInfo in
      let previews = previewTypeInfo.previews.compactMap { preview in
        let possibleId = possibleUniqueIdForPreview(preview, previewTypeInfo)
        let previewId = preview.getPreviewId()
        let previewCount = previewCountForId[possibleId] ?? 1
        let uniqueName = generateUniqueName(possibleId: possibleId, previewCount: previewCount, previewTypeInfo: previewTypeInfo, previewId: previewId)
        
        switch preview {
        case .previewProvider(let internalPreview, let previewType):
          return Preview(preview: internalPreview, type: previewType, uniqueName: uniqueName)
        case .previewRegistry(let anyValue):
          if #available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *),
              let realPreview = anyValue as? DeveloperToolsSupport.Preview {
            return Preview(preview: realPreview, uniqueName: uniqueName)
          }
          return nil
        }
      }
      return PreviewType(previewTypeInfo: previewTypeInfo, previews: previews)
    }
  }
  
  private static func possibleUniqueIdForPreview(_ preview: InternalPreview, _ previewTypeInfo: PreviewTypeInfo) -> String {
    var id = previewTypeInfo.fileID ?? previewTypeInfo.name
    if let displayName = preview.getDisplayName() {
      id += "_\(displayName)"
    }
    return id
  }
  
  private static func generateUniqueName(possibleId: String, previewCount: Int, previewTypeInfo: PreviewTypeInfo, previewId: String) -> String {
    if previewCount == 1 {
      return possibleId
    } else if let fileId = previewTypeInfo.fileID, let line = previewTypeInfo.line {
      return "\(fileId)_\(line)"
    } else {
      return "\(previewTypeInfo.name)_\(previewId)"
    }
  }
}

