//
//  ProductCard.swift
//  DemoModule
//
//  Created by Noah Martin on 7/3/23.
//

import SwiftUI

struct ProductCardView: View {
    var imageName: String
    var productName: String
    var price: Double

    var body: some View {
        VStack(spacing: 8) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(8)

            Text(productName)
                .font(.headline)
                .lineLimit(2)

            Text("$\(price, specifier: "%.2f")")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
        .shadow(color: .secondary, radius: 3, x: 0, y: 2)
    }
}

struct ProductCardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProductCardView(imageName: "product-image", productName: "Sample Product 1", price: 29.99)
                .colorScheme(.dark)
                .previewLayout(.fixed(width: 200, height: 250))

            ProductCardView(imageName: "product-image", productName: "Sample Product 2", price: 49.99)
                .previewLayout(.fixed(width: 200, height: 250))
        }
    }
}
