//
//  RideDetailView.swift
//  DemoApp
//
//  Created by Noah Martin on 7/3/23.
//

import SwiftUI

struct RideDetailView: View {
    var ride: Ride

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(ride.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .cornerRadius(12)
                .overlay(
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("$\(ride.price, specifier: "%.2f")")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(8)
                        }
                    }
                )

            VStack(alignment: .leading, spacing: 8) {
                Text(ride.name)
                    .font(.title)

                Text(ride.description)
                    .foregroundColor(.gray)

                HStack(spacing: 12) {
                    Image(systemName: "person.3.fill")
                        .foregroundColor(.gray)

                    Text("\(ride.capacity) Seats")
                        .foregroundColor(.gray)

                    Image(systemName: "clock.fill")
                        .foregroundColor(.gray)

                    Text("\(ride.duration) min")
                        .foregroundColor(.gray)
                }

                HStack(spacing: 12) {
                    Image(systemName: "location.fill")
                        .foregroundColor(.gray)

                    Text(ride.pickupLocation)
                        .foregroundColor(.gray)

                    Image(systemName: "arrow.right")
                        .foregroundColor(.gray)

                    Text(ride.dropoffLocation)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)

            Spacer()

            Button(action: {
                // Action for booking the ride
            }) {
                Text("Book Ride")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding()
        }
        .navigationBarTitle(ride.name, displayMode: .inline)
    }
}

struct RideDetailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RideDetailView(ride: Ride(
                imageName: "product-image",
                name: "Luxury Sedan",
                description: "Experience the ultimate comfort and style in our luxury sedan.",
                price: 39.99,
                capacity: 4,
                duration: 45,
                pickupLocation: "City Center",
                dropoffLocation: "Airport"
            ))
            .previewLayout(.sizeThatFits)

            RideDetailView(ride: Ride(
                imageName: "product-image",
                name: "Economy Car",
                description: "A budget-friendly option for your daily commutes.",
                price: 24.99,
                capacity: 2,
                duration: 30,
                pickupLocation: "Suburb",
                dropoffLocation: "Downtown"
            ))
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)

            RideDetailView(ride: Ride(
                imageName: "product-image",
                name: "SUV",
                description: "A spacious ride for your family outings and adventures.",
                price: 49.99,
                capacity: 6,
                duration: 60,
                pickupLocation: "Beach",
                dropoffLocation: "National Park"
            ))
            .environment(\.sizeCategory, .accessibilityExtraExtraLarge)
            .previewLayout(.sizeThatFits)
        }
    }
}

struct Ride {
    var imageName: String
    var name: String
    var description: String
    var price: Double
    var capacity: Int
    var duration: Int
    var pickupLocation: String
    var dropoffLocation: String
}
