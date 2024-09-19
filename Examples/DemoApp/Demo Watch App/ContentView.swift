//
//  ContentView.swift
//  Demo Watch App
//
//  Created by Noah Martin on 7/5/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

struct ExerciseButtonView: View {
    var imageName: String

    var body: some View {
      HStack {
          Image(systemName: imageName)
              .font(.title)
          Text("Start Workout")
              .font(.headline)
      }
      .foregroundColor(.white)
      .padding()
      .background(Color.green)
      .cornerRadius(10)
    }
}

struct ExerciseButtonView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ExerciseButtonView(imageName: "figure.walk.circle.fill")
                .previewDisplayName("Walk")
                .previewDevice("Apple Watch Series 6 - 40mm")
            ExerciseButtonView(imageName: "figure.run.circle.fill")
                .previewDisplayName("Run")
                .previewDevice("Apple Watch Series 6 - 40mm")
        }
        .previewLayout(.sizeThatFits)
    }
}
