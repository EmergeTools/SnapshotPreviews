//
//  RideOptionsView.swift
//  DemoApp
//
//  Created by Noah Martin on 7/3/23.
//

import SwiftUI

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
                    .foregroundColor(.gray)
                    .font(.subheadline)
                    .lineLimit(2)

                Text("$\(price, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundColor(.blue)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray, radius: 3, x: 0, y: 2)
    }
}

struct RideOptionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RideOptionView(title: "Economy", description: "Affordable and efficient", price: 19.99)
                .previewLayout(.sizeThatFits)
                .padding()

            RideOptionView(title: "Luxury", description: "Premium experience", price: 39.99)
                .previewLayout(.sizeThatFits)
                .padding()
        }
    }
}
