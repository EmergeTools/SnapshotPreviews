#if canImport(UIKit) && !os(watchOS) && !os(visionOS) && !os(tvOS)
import Foundation
import UIKit
import SwiftUI

extension UIInterfaceOrientation {
  func toInterfaceOrientationMask() -> UIInterfaceOrientationMask {
      switch self {
      case .portraitUpsideDown:
          return .portraitUpsideDown
      case .landscapeLeft:
          return .landscapeLeft
      case .landscapeRight:
          return .landscapeRight
      default:
          return .portrait
      }
  }
}

extension InterfaceOrientation {
  func toInterfaceOrientation() -> UIInterfaceOrientation {
      switch self {
      case .portraitUpsideDown:
          return .portraitUpsideDown
      case .landscapeLeft:
          return .landscapeLeft
      case .landscapeRight:
          return .landscapeRight
      default:
        return .portrait
      }
  }
}
#endif
