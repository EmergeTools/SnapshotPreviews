//
//  File.swift
//
//
//  Created by Noah Martin on 7/6/23.
//

import SwiftUI

fileprivate struct ViewSelector: _VariadicView_MultiViewRoot {
  let position: Int
    func body(children: _VariadicView.Children) -> some View {
      children[position]
    }
}

extension View {
  func selectSubview(_ position: Int) -> some View {
    _VariadicView.Tree(ViewSelector(position: position)) {
      self
    }
  }
}
