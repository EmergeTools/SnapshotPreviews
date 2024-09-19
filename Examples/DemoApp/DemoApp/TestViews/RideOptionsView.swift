//
//  RideOptionsView.swift
//  DemoApp
//
//  Created by Noah Martin on 7/3/23.
//

import SwiftUI
import DemoModule

struct RideOptionView: View {
    var title: String
    var description: String
    var price: Double

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)

                Text(description)
                .foregroundColor(Color(PlatformColor.systemGray))
                    .font(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(2)

                Text("$\(price, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundColor(Color(PlatformColor.systemBlue))
            }

            Spacer()

            Image(systemName: "chevron.right")
            .foregroundColor(Color(PlatformColor.systemGray))
        }
        .padding()
        .background(Color(PlatformColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray, radius: 3, x: 0, y: 2)
    }
}

struct RideOptionView_Previews: PreviewProvider {
    static var previews: some View {
      PreviewVariants(layout: .sizeThatFits) {
            RideOptionView(title: "Economy", description: "Affordable and efficient", price: 19.99)
                .padding()
                .previewVariant(named: "Ride Option View - Economy")

            RideOptionView(title: "Luxury", description: "Premium experience", price: 39.99)
                .padding()
                .previewVariant(named: "Ride Option View - Luxury")
        }
    }
}
