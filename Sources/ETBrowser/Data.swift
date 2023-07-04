//
//  File.swift
//  
//
//  Created by Noah Martin on 7/3/23.
//

import Foundation
import ETBrowserCore

public struct Data {
  let previews: [PreviewType]

  func previews(in module: String) -> [PreviewType] {
    previews.filter { $0.module == module }.sorted { $0.typeName < $1.typeName }
  }

  var modules: Set<String> {
    Set(previews.map { $0.module })
  }

  public static var `default`: Data {
    self.init(previews: findPreviews())
  }
}
