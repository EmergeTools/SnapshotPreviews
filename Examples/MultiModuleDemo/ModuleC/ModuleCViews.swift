import SwiftUI

public struct ModuleCIcon: View {
  public let symbolName: String

  public init(symbolName: String = "star.fill") {
    self.symbolName = symbolName
  }

  public var body: some View {
    Image(systemName: symbolName)
      .font(.title)
      .foregroundStyle(.yellow)
  }
}

public struct ModuleCBadge: View {
  public let count: Int

  public init(count: Int = 1) {
    self.count = count
  }

  public var body: some View {
    Text("\(count)")
      .font(.caption.weight(.bold))
      .padding(.horizontal, 10)
      .padding(.vertical, 6)
      .background(.blue, in: Capsule())
      .foregroundStyle(.white)
  }
}

#Preview("ModuleC Icon") {
  ModuleCIcon()
}

#Preview("Small") {
  ModuleCBadge(count: 1)
}

#Preview("Large") {
  ModuleCBadge(count: 99)
}
