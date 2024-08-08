//
//  NSImage+EMG.swift
//
//
//  Created by Noah Martin on 8/2/24.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

public extension NSImage {
  var emg: NSImageSnapshotsNamespace {
    .init(image: self)
  }

  struct NSImageSnapshotsNamespace {
    private let image: NSImage

    init(image: NSImage) {
      self.image = image
    }

    public func pngData() -> NSData? {
        guard let tiffData = image.tiffRepresentation,
              let bitmapImageRep = NSBitmapImageRep(data: tiffData) else {
            return nil
        }

        let pngData = bitmapImageRep.representation(using: .png, properties: [:])
        return pngData as NSData?
    }
  }
}
#endif
