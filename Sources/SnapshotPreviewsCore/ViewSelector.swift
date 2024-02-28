//
//  ViewSelector.swift
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

public class SnapshotViewModel: ObservableObject {
  @Published public var index: Int

  init(index: Int) {
    self.index = index
  }
}

public protocol SnapshotViewModelProviding: View {
  var viewModel: SnapshotViewModel { get }
}

struct ViewSelectorTree<Content: View>: SnapshotViewModelProviding {

  @ObservedObject var viewModel: SnapshotViewModel
  let content: Content

  init(_ model: SnapshotViewModel, @ViewBuilder _ content: () -> Content) {
    self.viewModel = model
    self.content = content()
  }

  var body: some View {
    _VariadicView.Tree(ViewSelector(position: viewModel.index)) {
      content
    }
  }
}
