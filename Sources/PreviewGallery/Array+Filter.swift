//
//  Array+Filter.swift
//  SnapshotPreviews
//
//  Created by Itay Brenner on 23/1/25.
//

extension Array {
  func filterWithText(_ text: String, _ nameForElement: @escaping ((Element) -> String)) -> [Element] {
    return self.filter { element in
      text.isEmpty ? true : nameForElement(element).lowercased().contains(text.lowercased())
    }
  }
}
