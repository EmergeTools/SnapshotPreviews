//
//  PreviewProviderExtraction.swift
//
//
//  Created by Noah Martin on 8/23/23.
//

import Foundation
import SwiftUI

class PreviewProviderExtraction<A: PreviewProvider> {

  lazy var previews: Result<[(any View, [any ViewModifier])], Error> = {
    let children = ViewInspection.children(of: A.previews)
    guard A._allPreviews.count == children.count else {
      return .failure(PreviewError.previewCountMismatch(expected: A._allPreviews.count, actual: children.count))
    }
    return .success(children)
  }()

}
