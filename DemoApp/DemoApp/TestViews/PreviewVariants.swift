import SwiftUI
import SnapshotPreviewsCore

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

        view.value
          .modifier(modifier.value)
          .previewDisplayName(displayName)
          .previewLayout(layout)
      }
    }
  }

  private let modifiers: [NamedViewModifier]
  private let layout: PreviewLayout
  private let views: [PreviewView]
}

struct AnyViewModifier: ViewModifier {
  func body(content: Content) -> some View {
    modifier(content)
  }

  init(modifier: @escaping (Content) -> any View) {
    self.modifier = {
      AnyView(modifier($0))
    }
  }

  let modifier: (Content) -> AnyView
  
}

struct NamedViewModifier {
  var name: String
  var value: AnyViewModifier
}

extension NamedViewModifier: Identifiable {
  var id: String { name }
}

extension NamedViewModifier {
  static var unmodified: NamedViewModifier {
    .init(name: "", value: .init { $0 })
  }

  static var darkMode: NamedViewModifier {
    .init(name: "Dark mode", value: .init { $0.environment(\.colorScheme, .dark) })
  }

  static var xxlTextSize: NamedViewModifier {
    .init(name: "XXL Text Size", value: .init { $0.dynamicTypeSize(.xxxLarge) })
  }
}

extension [NamedViewModifier] {
  /// The default named view modifiers in a ``PreviewVariants``.
  static var previewDefault: [NamedViewModifier] {
    [.unmodified, .darkMode, .xxlTextSize]
  }
}
