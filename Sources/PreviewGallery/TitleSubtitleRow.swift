//
//  TitleSubtitleRow.swift
//
//
//  Created by Noah Martin on 8/31/23.
//

import Foundation
import SwiftUI

struct TitleSubtitleRow: View {
  let title: String
  let subtitle: String
  
  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text(title)
          .font(.headline)
          .foregroundStyle(Color.primary)
        
        Text(subtitle)
          .font(.subheadline)
          .foregroundStyle(Color.secondary)
      }
      Spacer()
      Image(systemName: "chevron.right")
        .foregroundColor(Color.secondary)
    }
  }
}
