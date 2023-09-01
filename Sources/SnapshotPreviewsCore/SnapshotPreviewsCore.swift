import SwiftUI

extension View {
  fileprivate func applyModifier<M: ViewModifier>(_ mod: M) -> any View {
    return modifier(mod)
  }
}

public struct Preview: Identifiable {
  init<P>(preview: SwiftUI._Preview, extraction: PreviewProviderExtraction<P>) {
    previewId = "\(preview.id)"
    orientation = preview.interfaceOrientation
    displayName = preview.displayName
    device = preview.device
    layout = preview.layout
    let _view = {
      let children = try extraction.previews.get()

      let (v, modifiers) = children[preview.id]
      var result = v
      for mod in modifiers {
        result = result.applyModifier(mod)
      }
      return AnyView(result)
    }
    self._view = _view
    _colorScheme = {
      let v = try _view()
      return ViewInspection.preferredColorScheme(of: v)
    }
  }

#if swift(>=5.9)
  @available(iOS 17.0, *)
  init?(preview: DeveloperToolsSupport.Preview) {
    previewId = "0"
    orientation = nil
    device = nil
    let preview = Mirror(reflecting: preview)
    let traits = preview.descendant("traits")! as! [Any]
    var layout = PreviewLayout.device
    for t in traits {
      if let value = Mirror(reflecting: t).descendant("value") as? PreviewLayout {
        layout = value
      }
    }
    self.layout = layout
    displayName = preview.descendant("displayName") as? String
    let source = Mirror(reflecting: preview.descendant("source")!)
    let sourceType = source.subjectType
    let _view: @MainActor () throws -> AnyView
    if (String(describing: sourceType) == "ViewPreviewSource") {
      _view = {
        let makeView = source.descendant("makeView") as! @MainActor () -> any SwiftUI.View
        return AnyView(makeView())
      }
    } else if (String(describing: sourceType) == "UIViewPreviewSource") {
      _view = {
        let makeView = source.descendant("makeView") as! () -> UIView
        return AnyView(UIViewWrapper(makeView))
      }
    } else if (String(describing: sourceType) == "UIViewControllerPreviewSource") {
      _view = {
        let makeViewController = source.descendant("makeViewController") as! () -> UIViewController
        return AnyView(UIViewControllerWrapper(makeViewController))
      }
    } else {
      return nil
    }

    self._view = _view
    _colorScheme = {
      let v = try _view()
      return ViewInspection.preferredColorScheme(of: v)
    }
  }
#endif

  public let id = UUID()
  public let previewId: String
  public let orientation: InterfaceOrientation?
  public let displayName: String?
  public let device: PreviewDevice?
  public let layout: PreviewLayout
  private let _colorScheme: @MainActor () throws -> ColorScheme?
  @MainActor public func colorScheme() throws -> ColorScheme? {
    try _colorScheme()
  }
  private let _view: @MainActor () throws -> AnyView
  @MainActor public func view() throws -> AnyView {
    try _view()
  }
}

// Wraps PreviewProvider or PreviewRegistry
public struct PreviewType: Hashable, Identifiable {
  init<A: PreviewProvider>(typeName: String, preivewProvider: A.Type) {
    self.typeName = typeName
    self.fileID = nil
    let extraction = PreviewProviderExtraction<A>()
    self.previews = A._allPreviews.map { Preview(preview: $0, extraction: extraction) }
    self.platform = A.platform
  }

#if swift(>=5.9)
  @available(iOS 17.0, *)
  init?<A: PreviewRegistry>(typeName: String, registry: A.Type) {
    self.typeName = typeName
    self.fileID = A.fileID
    guard let internalPreview = try? A.makePreview(), let preview = Preview(preview: internalPreview)  else {
      return nil
    }
    self.previews = [preview]
    self.platform = nil
  }
#endif

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
      return String(fileID.split(separator: "/").last!.split(separator: ".").first!)
    }
    let components = typeName
      .split(separator: ".")
      .dropFirst()
      .flatMap { $0.split(separator: "_") }
      .joined(separator: " ")
      .splitBefore(separator: { $0.isUpperCase })
      .map{ String($0).trimmingCharacters(in: .whitespaces) }
      .filter { $0.count > 0 }
    if components.last == "Previews" {
      return components.dropLast().joined(separator: " ")
    }
    return components.joined(separator: " ")
  }

  public let id = UUID()
  public let fileID: String?
  public let typeName: String
  public var previews: [Preview]
  public let platform: PreviewPlatform?
}

public func findPreviews(
  shouldInclude: (String) -> Bool = { _ in true },
  willAccess: (String) -> Void = { _ in }) -> [PreviewType]
{
  return getPreviewTypes()
    .filter { shouldInclude($0.name) }
    .compactMap { conformance -> PreviewType? in
      let (name, accessor, proto) = conformance
      willAccess(name)
      switch proto {
      case "PreviewProvider":
        let previewProvider = unsafeBitCast(accessor(), to: Any.Type.self) as! any PreviewProvider.Type
        return PreviewType(typeName: name, preivewProvider: previewProvider)
      case "PreviewRegistry":
  #if swift(>=5.9)
        if #available(iOS 17.0, *) {
          let previewRegistry = unsafeBitCast(accessor(), to: Any.Type.self) as! any PreviewRegistry.Type
          return PreviewType(typeName: name, registry: previewRegistry)
        }
  #endif
        return nil
      default:
        return nil
      }
  }
}

extension Sequence {
    func splitBefore(
        separator isSeparator: (Iterator.Element) throws -> Bool
    ) rethrows -> [AnySequence<Iterator.Element>] {
        var result: [AnySequence<Iterator.Element>] = []
        var subSequence: [Iterator.Element] = []

        var iterator = self.makeIterator()
        while let element = iterator.next() {
            if try isSeparator(element) {
                if !subSequence.isEmpty {
                    result.append(AnySequence(subSequence))
                }
                subSequence = [element]
            }
            else {
                subSequence.append(element)
            }
        }
        result.append(AnySequence(subSequence))
        return result
    }
}

extension Character {
    var isUpperCase: Bool { return String(self) == String(self).uppercased() }
}
