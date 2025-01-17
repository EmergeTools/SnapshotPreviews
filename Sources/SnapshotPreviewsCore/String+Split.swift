//
//  String+Split.swift
//  SnapshotPreviews
//
//  Created by Noah Martin on 1/17/25.
//

extension String {
  var splittingHumanReadableName: [String] {
    return split(separator: ".").flatMap { $0.split(separator: "_") }
      .joined(separator: " ")
      .splitBefore(separator: { $0.isUpperCase && !($1?.isUpperCase ?? true) })
      .map { String($0).trimmingCharacters(in: .whitespaces) }
      .filter { $0.count > 0 }
  }
}

extension Sequence {
    func splitBefore(
        separator isSeparator: (Iterator.Element, Iterator.Element?) throws -> Bool
    ) rethrows -> [AnySequence<Iterator.Element>] {
        var result: [AnySequence<Iterator.Element>] = []
        var subSequence: [Iterator.Element] = []

        var iterator = self.makeIterator()
        var currentElement = iterator.next()
        while let element = currentElement {
          let nextElement = iterator.next()
          if try isSeparator(element, nextElement) {
                if !subSequence.isEmpty {
                    result.append(AnySequence(subSequence))
                }
                subSequence = [element]
            }
            else {
                subSequence.append(element)
            }
          currentElement = nextElement
        }
        result.append(AnySequence(subSequence))
        return result
    }
}

extension Character {
    var isUpperCase: Bool { return String(self) == String(self).uppercased() }
}
