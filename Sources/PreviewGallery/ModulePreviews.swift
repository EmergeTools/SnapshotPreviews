//
//  ModulePreviews.swift
//
//
//  Created by Noah Martin on 7/3/23.
//

import Foundation
import SwiftUI
import SnapshotPreviewsCore

struct ModulePreviews: View {
  let module: String
  let data: PreviewData
  
  var body: some View {
    let componentProviders = data.previews(in: module).filter { provider in
      return provider.previews.contains { preview in
        return !preview.requiresFullScreen
      }
    }
    let featureProviders = data.previews(in: module).filter { provider in
      return provider.previews.contains { preview in
        return preview.requiresFullScreen
      }
    }
    return NavigationLink(module) {
      List {
        if !featureProviders.isEmpty {
          TitleSubtitleRow(
            title: "Screens",
            subtitle: "\(featureProviders.count) Preview\(featureProviders.count != 1 ? "s" : "")")
          .background(
            NavigationLink(destination: ModuleScreens(module: module, data: data), label: {})
                .opacity(0)
          )
          .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
        }
        ForEach(componentProviders) { preview in
          PreviewCellView(preview: preview)
            .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
        }
      }
      .listStyle(.plain)
      .navigationTitle(module)
    }
  }
}

#if DEBUG
struct ModulePreviews_Preview: PreviewProvider {
  static var previews: some View {
    let testData = PreviewData(
      previews: [
        PreviewType(typeName: "TestModule.ModulePreviews_TestPreview1", preivewProvider: ModulePreviews_TestPreview1.self),
        PreviewType(typeName: "TestModule.ModulePreviews_TestPreview2", preivewProvider: ModulePreviews_TestPreview2.self),
      ]
    )
    ModulePreviews(module: "TestModule", data: testData)
  }
}

private struct ModulePreviews_TestPreview1: PreviewProvider {
  static var previews: some View {
    VStack {
      Text("Hello world")
      Text("Hello world2")
      Text("Hello world3")
    }
    .previewLayout(.sizeThatFits)
  }
}

private struct ModulePreviews_TestPreview2: PreviewProvider {
  static var previews: some View {
    VStack {
      Text("Hello world")
      Text("Hello world2")
      Text("Hello world3")
    }
    .previewLayout(.sizeThatFits)
  }
}
#endif
