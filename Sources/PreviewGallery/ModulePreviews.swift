//
//  File.swift
//  
//
//  Created by Noah Martin on 7/3/23.
//

import Foundation
import SwiftUI

struct ModulePreviews: View {
  let module: String
  let data: Data

  var body: some View {
      NavigationLink(module) {
        ScrollView {
          LazyVStack(alignment: .leading) {
            ForEach(data.previews(in: module)) { preview in
              PreviewCellView(preview: preview)
            }
          }
        }
        .navigationTitle(module)
      }
  }
}
