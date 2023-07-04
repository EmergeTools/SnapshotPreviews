//
//  File.swift
//  
//
//  Created by Noah Martin on 7/3/23.
//

import Foundation
import SwiftUI
import ETBrowserCore

struct PreviewCellView: View {
    let preview: PreviewType

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
          NavigationLink {
            ScrollView {
              VStack(alignment: .leading) {
                ForEach(preview.previews) { preview in
                  Text(preview.displayName ?? "Preview")
                    .font(.headline)
                    .foregroundStyle(.black)
                    .padding(.leading, 8)
                  preview.view()
                    .border(Color.black)
                    .background {
                      Checkerboard()
                        .foregroundStyle(.black)
                        .opacity(0.1)
                    }
                  Divider()
                }
              }
            }
            .navigationTitle(preview.displayName)
          } label: {
            HStack {
              VStack(alignment: .leading) {
                Text(preview.displayName)
                  .font(.headline)
                  .foregroundStyle(.black)
                  .padding(.leading, 8)
                
                Text("\(preview.previews.count) Preview\(preview.previews.count != 1 ? "s" : "")")
                  .font(.subheadline)
                  .foregroundStyle(.gray)
                  .padding(.leading, 8)
              }
              Spacer()
              Image(systemName: "chevron.right")
                  .foregroundColor(.gray)
                  .padding(.trailing, 8)
            }
          }

          preview.previews[0].view()
            .border(Color.black)
            .background {
              Checkerboard()
                .foregroundStyle(.black)
                .opacity(0.1)
            }
          Divider()
        }
    }
}

public struct ETBrowser: View {

  let data: Data

  public init(data: Data = .default) {
    self.data = data
  }

  public var body: some View {
    if data.modules.count > 1 {
      List {
          ForEach(Array(data.modules).sorted(), id: \.self) { module in
            ModulePreviews(module: module, data: data)
          }
      }.navigationTitle("Modules")
    } else {
      ModulePreviews(module: data.modules.first!, data: data)
    }
  }
}
