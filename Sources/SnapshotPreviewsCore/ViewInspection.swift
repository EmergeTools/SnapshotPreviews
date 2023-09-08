//
//  File.swift
//
//
//  Created by Noah Martin on 7/6/23.
//

import SwiftUI

public enum ViewInspection {

   static func attribute(label: String, value: Any) -> Any? {
      let mirror = (value as? Mirror) ?? Mirror(reflecting: value)
      return mirror.descendant(label)
   }

   static func tupleChildren(_ content: Any) -> [any View] {
      let tupleViews = Self.attribute(label: "value", value: content)!
      let childrenCount = Mirror(reflecting: tupleViews).children.count
      return (0..<childrenCount).map { Self.attribute(label: ".\($0)", value: tupleViews) as! any View }
   }

  public static func childrenIfMultiple(of view: some View) -> [(any View, [any ViewModifier])] {
    let children = children(of: view)
    if children.count == 1 {
      return [(view, [])]
    }
    return children
  }

  private static func children(of view: some View) -> [(any View, [any ViewModifier])] {
    let viewType = type(of: view)
    let typeName = String(reflecting: viewType)
    if typeName.starts(with: "SwiftUI._ConditionalContent") {
      let storage = Self.attribute(label: "storage", value: view)!
      if let trueContent = Self.attribute(label: "trueContent", value: storage) as? any View {
        return childrenIfMultiple(of: trueContent)
      } else {
        let content = Self.attribute(label: "falseContent", value: storage) as! any View
        return childrenIfMultiple(of: content)
      }
    } else if typeName.starts(with: "SwiftUI.EmptyView") {
      return []
    } else if typeName.starts(with: "SwiftUI.Tuple") {
      return tupleChildren(view).flatMap { childrenIfMultiple(of: $0) }
    } else if typeName.starts(with: "SwiftUI.Group") {
      let content = Self.attribute(label: "content", value: view) as! any View
      return childrenIfMultiple(of: content)
    } else if typeName.starts(with: "SwiftUI.ForEach"), let provider = view as? ViewsProvider {
      return provider.views().flatMap { childrenIfMultiple(of: $0) }
    } else if typeName.starts(with: "SwiftUI.AnyView") {
      let storage = Self.attribute(label: "storage", value: view)!
      let storageView = Self.attribute(label: "view", value: storage) as! any View
      return childrenIfMultiple(of: storageView)
    } else if typeName.starts(with: "SwiftUI.ModifiedContent") {
      let content = Self.attribute(label: "content", value: view) as! any View
      let modifier = Self.attribute(label: "modifier", value: view) as! any ViewModifier
      return childrenIfMultiple(of: content).map { (view, modifiers) in
        var modifiers = modifiers
        modifiers.append(modifier)
        return (view, modifiers)
      }
    }
    if viewType.Body != Never.self && !typeName.starts(with: "SwiftUI.") {
      return childrenIfMultiple(of: view.body)
    }
    return [(view, [])]
  }

  private static func getModifier<T>(of view: some View, parseModifier: (Any) -> T?) -> T? {
    let typeName = String(reflecting: type(of: view))
    if typeName.starts(with: "SwiftUI.ModifiedContent") {
      let modifier = Self.attribute(label: "modifier", value: view)!
      if let result = parseModifier(modifier) {
        return result
      }
      let content = Self.attribute(label: "content", value: view) as! any View
      return getModifier(of: content, parseModifier: parseModifier)
    } else if typeName.starts(with: "SwiftUI.AnyView") {
      let storage = Self.attribute(label: "storage", value: view)!
      let storageView = Self.attribute(label: "view", value: storage) as! any View
      return getModifier(of: storageView, parseModifier: parseModifier)
    }
    return nil
  }

  public static func preferredColorScheme(of view: some View) -> ColorScheme? {
    return getModifier(of: view) { modifier in
      if let colorSchemePreference = modifier as? _PreferenceWritingModifier<PreferredColorSchemeKey> {
        return colorSchemePreference.value
      } else if let colorScheme = modifier as? _EnvironmentKeyWritingModifier<ColorScheme> {
        return colorScheme.value
      }
      return nil
    }
  }

  public static func precision(of view: some View) -> Float? {
    return getModifier(of: view) { modifier in
      let typeName = String(reflecting: modifier)
      if typeName.contains(".EmergePrecisionModifier") {
        if let precision = Self.attribute(label: "precision", value: modifier) as? Float {
          return precision
        }
      }
      return nil
    }
  }

  public static func shouldExpand(_ view: some View) -> Bool {
    return getModifier(of: view) { modifier in
      let typeName = String(reflecting: modifier)
      if typeName.contains(".EmergeExpansionModifier") {
        if let enabled = Self.attribute(label: "enabled", value: modifier) as? Bool {
          return enabled
        }
      }
      return true
    } ?? true
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
