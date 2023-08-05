@resultBuilder
struct ArrayBuilder<Element> {
    static func buildPartialBlock(first: Element) -> [Element] { [first] }
    static func buildPartialBlock(first: [Element]) -> [Element] { first }
    static func buildPartialBlock(accumulated: [Element], next: Element) -> [Element] { accumulated + [next] }
    static func buildPartialBlock(accumulated: [Element], next: [Element]) -> [Element] { accumulated + next }

    // Empty Case
    static func buildBlock() -> [Element] { [] }
    // If/Else
    static func buildEither(first: [Element]) -> [Element] { first }
    static func buildEither(second: [Element]) -> [Element] { second }
    // Just ifs
    static func buildIf(_ element: [Element]?) -> [Element] { element ?? [] }
    // fatalError()
    static func buildPartialBlock(first: Never) -> [Element] {}
}
