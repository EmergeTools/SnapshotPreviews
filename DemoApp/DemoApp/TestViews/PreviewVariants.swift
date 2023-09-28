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

        AnyView(view.value.applyModifier(modifier.value))
          .previewDisplayName(displayName)
          .previewLayout(layout)
      }
    }
  }

  private let modifiers: [NamedViewModifier]
  private let layout: PreviewLayout
  private let views: [PreviewView]
}

extension View {
  fileprivate func applyModifier<M: ViewModifier>(_ mod: M) -> any View {
    return modifier(mod)
  }
}

struct NamedViewModifier {
  var name: String
  var value: any ViewModifier
}

extension NamedViewModifier: Identifiable {
  var id: String { name }
}

extension NamedViewModifier {
  static var unmodified: NamedViewModifier {
    .init(name: "", value: EmptyModifier())
  }

  static var darkMode: NamedViewModifier {
    .init(name: "Dark mode", value: _PreferenceWritingModifier<PreferredColorSchemeKey>(value: .dark))
  }

  static var xxlTextSize: NamedViewModifier {
    .init(name: "XXL Text Size", value: _EnvironmentKeyWritingModifier<DynamicTypeSize>(keyPath: \.dynamicTypeSize, value: .xxxLarge))
  }
}

extension [NamedViewModifier] {
  /// The default named view modifiers in a ``PreviewVariants``.
  static var previewDefault: [NamedViewModifier] {
    [.unmodified, .darkMode, .xxlTextSize]
  }
}
