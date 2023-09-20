//
//  RowView.swift
//  DemoModule
//
//  Created by Noah Martin on 7/3/23.
//

import Foundation
import SwiftUI

public struct RowView: View {
    var imageName: String
    var productName: String
    var ratings: Double

  public init(imageName: String, productName: String, ratings: Double) {
    self.imageName = imageName
    self.productName = productName
    self.ratings = ratings
  }

    public var body: some View {
        HStack {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 8) {
                Text(productName)
                    .font(.headline)
                    .lineLimit(2)

                HStack(spacing: 4) {
                    ForEach(0..<5) { index in
                        Image(systemName: ratings >= Double(index + 1) ? "star.fill" : "star")
                        .foregroundColor(Color(UIColor.systemYellow))
                            .font(.caption)
                    }
                }
            }
        }
        .padding(8)
    }
}

#if swift(>=5.9)
#Preview("New test") {
  RowView(
    imageName: "product-image",
    productName: "New Preview test",
    ratings: 4.2)
  .preferredColorScheme(.dark)
}
#endif

struct RowView_Previews: PreviewProvider {
  static var previews: some View {
    RowView(
      imageName: "product-image",
      productName: "My Awesome Item",
      ratings: 4.2)
    .previewDisplayName("RowView")
    .previewLayout(.sizeThatFits)
    .preferredColorScheme(.dark)
  }
}
