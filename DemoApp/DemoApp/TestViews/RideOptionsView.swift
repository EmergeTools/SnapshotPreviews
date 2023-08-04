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
                .foregroundColor(Color(uiColor: UIColor.systemGray))
                    .font(.subheadline)
                    .lineLimit(2)

                Text("$\(price, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundColor(Color(uiColor: UIColor.systemBlue))
            }

            Spacer()

            Image(systemName: "chevron.right")
            .foregroundColor(Color(uiColor: UIColor.systemGray))
        }
        .padding()
        .background(Color(uiColor: UIColor.systemBackground))
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
