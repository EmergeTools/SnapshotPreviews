//
//  File.swift
//
//
//  Created by Noah Martin on 7/6/23.
//

import SwiftUI

enum ViewInspection {

   static func attribute(label: String, value: Any) -> Any? {
      let mirror = (value as? Mirror) ?? Mirror(reflecting: value)
      return mirror.descendant(label)
   }

   static func tupleChildren(_ content: Any) -> [any View] {
      let tupleViews = Self.attribute(label: "value", value: content)!
      let childrenCount = Mirror(reflecting: tupleViews).children.count
      return (0..<childrenCount).map { Self.attribute(label: ".\($0)", value: tupleViews) as! any View }
   }

   public static func children(of view: some View) -> [any View] {
      let typeName = String(reflecting: type(of: view))
      if typeName.starts(with: "SwiftUI.Tuple") {
         return Self.tupleChildren(view).flatMap { Self.children(of: $0) }
      } else if typeName.starts(with: "SwiftUI.Group") {
         let content = Self.attribute(label: "content", value: view) as! any View
         return children(of: content)
      } else if typeName.starts(with: "SwiftUI.ForEach"), let provider = view as? ViewsProvider {
         return provider.views()
      }
      return [view]
   }
}

protocol ViewsProvider {
   func views() -> [any View]
}

extension ForEach: ViewsProvider where Content: View {

   func views() -> [any View] {

      typealias Builder = (Data.Element) -> Content
      let data = ViewInspection.attribute(label: "data", value: self) as! Data
      let builder = ViewInspection.attribute(label: "content", value: self) as! Builder
      let indecies = (0..<data.count).map { i in
         return data.index(data.startIndex, offsetBy: i)
      }
      return indecies.map { builder(data[$0]) }
   }
}
