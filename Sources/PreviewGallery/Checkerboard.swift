//
//  Checkerboard.swift
//
//
//  Created by Noah Martin on 7/4/23.
//

import SwiftUI

struct Checkerboard: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()

    let rowSize: Double = 10
    let columnSize: Double = 10

    let rows = Int(rect.height / CGFloat(rowSize))
    let columns = Int(rect.width / CGFloat(columnSize))
    let columnRemainder = rect.width - Double(columns) * columnSize
    let rowRemainder = rect.height - Double(rows) * rowSize

    for row in 0 ..< rows {
      for column in 0 ..< columns {
        if (row + column).isMultiple(of: 2) {
          let startX = Double(columnSize) * Double(column)
          let startY = Double(rowSize) * Double(row)

          let rect = CGRect(x: startX, y: startY, width: columnSize, height: rowSize)
          path.addRect(rect)
        }
      }
      if (row + columns).isMultiple(of: 2) {
        if columnRemainder > 0 {
          let startX = Double(columnSize) * Double(columns)
          let startY = Double(rowSize) * Double(row)

          let rect = CGRect(x: startX, y: startY, width: columnRemainder, height: rowSize)
          path.addRect(rect)
        }
      }
    }
    if rowRemainder > 0 {
      for column in 0..<columns {
        if (rows + column).isMultiple(of: 2) {
          let startX = Double(columnSize) * Double(column)
          let startY = Double(rowSize) * Double(rows)

          let rect = CGRect(x: startX, y: startY, width: columnSize, height: rowRemainder)
          path.addRect(rect)
        }
      }
      if (rows + columns).isMultiple(of: 2) {
        let startX = Double(columnSize) * Double(columns)
        let startY = Double(rowSize) * Double(rows)

        let rect = CGRect(x: startX, y: startY, width: columnRemainder, height: rowRemainder)
        path.addRect(rect)
      }
    }

    return path
  }
}

#if DEBUG
private struct CheckerboardView: View {
  var body: some View {
    VStack {
      Text("Hello world")
    }
    .background {
      Checkerboard()
        .foregroundStyle(Color(UIColor.label))
        .opacity(0.1)
        .background(Color(UIColor.systemBackground))
    }
  }
}

private struct CheckerboardView_Preview: PreviewProvider {
  static var previews: some View {
    CheckerboardView()
      .previewLayout(.fixed(width: 300, height: 300))
  }
}
#endif
