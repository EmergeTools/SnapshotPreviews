import SwiftUI

public struct ModuleBCard: View {
  public let title: String
  public let subtitle: String

  public init(title: String = "ModuleB Card", subtitle: String = "Subtitle") {
    self.title = title
    self.subtitle = subtitle
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(title)
        .font(.headline)
      Text(subtitle)
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(14)
    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
  }
}

#Preview("Compact") {
  ModuleBCard(subtitle: "Compact layout")
    .frame(width: 220)
}

#Preview("Expanded") {
  ModuleBCard(subtitle: "Expanded layout")
    .frame(width: 340)
}
