import SwiftUI

struct PreviewView: Identifiable {
  let id = UUID()
  let value: AnyView
  let name: String
}

extension View {
  func previewVariant(named name: String) -> PreviewView {
    PreviewView(value: AnyView(self), name: name)
  }
}

struct PreviewVariants: View {

  init(
    modifiers: [NamedViewModifier] = .previewDefault,
    layout: PreviewLayout = .device,
    @ArrayBuilder<PreviewView> views: () -> [PreviewView])
  {
    self.modifiers = modifiers
    self.layout = layout
    self.views = views()
  }

  var body: some View {
    ForEach(modifiers) { modifier in
      ForEach(views) { view in
        let displayName = [view.name, modifier.name]
          .filter { !$0.isEmpty }
          .joined(separator: ", ")

        AnyView(modifier.value(view.value))
          .previewDisplayName(displayName)
          .previewLayout(layout)
      }
    }
  }

  private let modifiers: [NamedViewModifier]
  private let layout: PreviewLayout
  private let views: [PreviewView]
}

struct NamedViewModifier {
  var name: String
  var value: (any View) -> any View
}

extension NamedViewModifier: Identifiable {
  var id: String { name }
}

extension NamedViewModifier {
  static var unmodified: NamedViewModifier {
    .init(name: "", value: { $0 })
  }

  static var darkMode: NamedViewModifier {
    .init(name: "Dark mode", value: { $0.preferredColorScheme(.dark).environment(\.colorScheme, .dark) })
  }

  static var landscape: NamedViewModifier {
    .init(name: "Landscape", value: { $0.previewInterfaceOrientation(.landscapeLeft) })
  }

  static var xxlTextSize: NamedViewModifier {
    .init(name: "XXL Text Size", value: { $0.dynamicTypeSize(.xxxLarge) })
  }

  @available(macOS, unavailable)
  @available(watchOS, unavailable)
  @available(visionOS, unavailable)
  @available(tvOS, unavailable)
  static var accessibility: NamedViewModifier {
    .init(name: "Accessibility", value: { $0.emergeAccessibility(true) })
  }

  static var rtl: NamedViewModifier {
    .init(name: "RTL", value: { $0.environment(\.layoutDirection, .rightToLeft) })
  }
}

extension [NamedViewModifier] {
  /// The default named view modifiers in a ``PreviewVariants``.
  static var previewDefault: [NamedViewModifier] {
    #if os(iOS)
    if UserDefaults.standard.bool(forKey: "NSDoubleLocalizedStrings") {
      return [.unmodified, .darkMode, .xxlTextSize, .rtl, .landscape]
    }
    return [.unmodified, .darkMode, .xxlTextSize, .rtl, .accessibility, .landscape]
    #else
    [.unmodified, .darkMode, .rtl]
    #endif
  }
}
