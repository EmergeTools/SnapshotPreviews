//
//  PreviewError.swift
//  
//
//  Created by Noah Martin on 8/22/23.
//

import Foundation

enum PreviewError: Error {
  case previewCountMismatch(expected: Int, actual: Int)
}

extension PreviewError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .previewCountMismatch(let expected, let actual):
      return "Expected \(expected) previews but found \(actual). Please file a bug."
    }
  }
}
