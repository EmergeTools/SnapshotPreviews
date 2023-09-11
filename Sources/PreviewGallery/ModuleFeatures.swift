//
//  ModuleFeatures.swift
//
//
//  Created by Noah Martin on 8/31/23.
//

import Foundation
import SwiftUI
import SnapshotPreviewsCore

struct ModuleFeatures: View {
  
  let module: String
  let data: PreviewData
  
  var body: some View {
    let featureProviders = data.previews(in: module).filter { provider in
      return provider.previews.contains { preview in
        return preview.requiresFullScreen
      }
    }
    return List {
      ForEach(featureProviders) { provider in
        let featurePreviews = provider.previews.filter { $0.requiresFullScreen }
        NavigationLink {
          if featurePreviews.count == 1 {
            try! featurePreviews[0].view()
          } else {
            List {
              ForEach(featurePreviews) { preview in
                NavigationLink(preview.displayName ?? provider.displayName) {
                  try! preview.view()
                }
              }
            }.navigationTitle(provider.displayName)
          }
        } label: {
          VStack(alignment: .leading) {
            Text(provider.displayName)
              .font(.headline)
              .foregroundStyle(Color(UIColor.label))
              .padding(.leading, 8)
            
            Text("\(featurePreviews.count) Preview\(featurePreviews.count != 1 ? "s" : "")")
              .font(.subheadline)
              .foregroundStyle(Color(UIColor.secondaryLabel))
              .padding(.leading, 8)
          }
        }
      }
    }.navigationTitle("Screens")
  }
  
}

#if DEBUG
struct ModuleFeatures_Preview: PreviewProvider {
  static var previews: some View {
    ModuleFeatures(
      module: "TestModule",
      data: PreviewData(
        previews: [
          PreviewType(typeName: "TestModule.ModuleFeatures_TestPreview", preivewProvider: ModuleFeatures_TestPreview.self),
          PreviewType(typeName: "TestModule.ModuleFeatures_TestPreview2", preivewProvider: ModuleFeatures_TestPreview2.self)
        ]
      )
    )
  }
}

private struct ModuleFeatures_TestPreview: PreviewProvider {
  static var previews: some View {
    Text("Hello world")
    Text("Hello world2")
    Text("Hello world3")
  }
}

private struct ModuleFeatures_TestPreview2: PreviewProvider {
  static var previews: some View {
    VStack {
      Text("Hello world")
      Text("Hello world2")
      Text("Hello world3")
    }
  }
}
#endif
