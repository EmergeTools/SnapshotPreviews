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
          .foregroundStyle(Color.black)

        Text(subtitle)
          .font(.subheadline)
          .foregroundStyle(Color.secondary)
      }
        .padding(.leading, 8)
      Spacer()
      Image(systemName: "chevron.right")
        .foregroundColor(Color.secondary)
        .padding(.trailing, 8)
    }
  }
}

#if DEBUG
struct TitleSubtitleRow_Preview: PreviewProvider {
  static var previews: some View {
    TitleSubtitleRow(title: "SuperAwesomeType", subtitle: "Regular display")
      .previewLayout(.sizeThatFits)
  }
}
#endif
