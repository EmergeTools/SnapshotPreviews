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

  public static func children(of view: some View) -> [(any View, [any ViewModifier])] {
    let viewType = type(of: view)
    let typeName = String(reflecting: viewType)
    if typeName.starts(with: "SwiftUI._ConditionalContent") {
      let storage = Self.attribute(label: "storage", value: view)!
      if let trueContent = Self.attribute(label: "trueContent", value: storage) as? any View {
        return children(of: trueContent)
      } else {
        let content = Self.attribute(label: "falseContent", value: storage) as! any View
        return children(of: content)
      }
    } else if typeName.starts(with: "SwiftUI.EmptyView") {
      return []
    } else if typeName.starts(with: "SwiftUI.Tuple") {
       return Self.tupleChildren(view).flatMap { children(of: $0) }
    } else if typeName.starts(with: "SwiftUI.Group") {
       let content = Self.attribute(label: "content", value: view) as! any View
       return children(of: content)
    } else if typeName.starts(with: "SwiftUI.ForEach"), let provider = view as? ViewsProvider {
      return provider.views().flatMap { children(of: $0) }
    } else if typeName.starts(with: "SwiftUI.AnyView") {
      let storage = Self.attribute(label: "storage", value: view)!
      let storageView = Self.attribute(label: "view", value: storage) as! any View
      return children(of: storageView)
    } else if typeName.starts(with: "SwiftUI.ModifiedContent") {
      let content = Self.attribute(label: "content", value: view) as! any View
      let modifier = Self.attribute(label: "modifier", value: view) as! any ViewModifier
      return children(of: content).map { (view, modifiers) in
        var modifiers = modifiers
        modifiers.append(modifier)
        return (view, modifiers)
      }
    }
    if viewType.Body != Never.self && !typeName.starts(with: "SwiftUI.") {
      return children(of: view.body)
    }
    return [(view, [])]
   }

  public static func preferredColorScheme(of view: some View) -> ColorScheme? {
    let typeName = String(reflecting: type(of: view))
    if typeName.starts(with: "SwiftUI.ModifiedContent") {
      let modifier = Self.attribute(label: "modifier", value: view)!
      if let colorSchemePreference = modifier as? _PreferenceWritingModifier<PreferredColorSchemeKey> {
        return colorSchemePreference.value
      } else if let colorSchemePreference = modifier as? _PreferenceWritingModifier<PreferredColorSchemeKey> {
        return colorSchemePreference.value
      } else {
        let content = Self.attribute(label: "content", value: view) as! any View
        return preferredColorScheme(of: content)
      }
    } else if typeName.starts(with: "SwiftUI.AnyView") {
      let storage = Self.attribute(label: "storage", value: view)!
      let storageView = Self.attribute(label: "view", value: storage) as! any View
      return preferredColorScheme(of: storageView)
    }
    return nil
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
