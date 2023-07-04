//
//  ButtonView.swift
//  DemoModule
//
//  Created by Noah Martin on 7/3/23.
//

import SwiftUI

struct ButtonView<T: ShapeStyle>: View {
    var title: String
    var background: T
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(background)
                .cornerRadius(8)
        }.padding()
    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ButtonView(title: "Click Me", background: Color.blue) {
                print("Button clicked")
            }
            .previewDisplayName("ButtonView - Solid")
            .previewLayout(.sizeThatFits)

            ButtonView(title: "Click Me", background: LinearGradient(gradient: Gradient(colors: [Color.blue, Color.green]), startPoint: .leading, endPoint: .trailing)) {
                print("Button clicked")
            }
            .previewDisplayName("ButtonView - Gradient")
            .previewLayout(.sizeThatFits)
        }
    }
}
