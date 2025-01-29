//
//  DateView.swift
//  DemoApp
//
//  Created by Noah Martin on 12/28/23.
//

import SwiftUI

struct DateView: View {
  let currentDate = Date()

    var body: some View {
        Text(currentDate, style: .date)
            .font(.title)
            .padding()
    }
}

struct DateView_Previews: PreviewProvider {
    static var previews: some View {
        DateView()
    }
}
