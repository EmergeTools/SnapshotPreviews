//
//  UIImage+EMG.swift
//
//
//  Created by Noah Martin on 8/8/24.
//

#if canImport(UIKit)
import UIKit

public extension UIImage {
  var emg: UIImageSnapshotsNamespace {
    .init(image: self)
  }

  struct UIImageSnapshotsNamespace {
    private let image: UIImage

    init(image: UIImage) {
      self.image = image
    }

    public func pngData() -> Data? {
      image.pngData()
    }
  }
}
#endif
