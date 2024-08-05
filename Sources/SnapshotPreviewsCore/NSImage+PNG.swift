//
//  NSImage+PNG.swift
//
//
//  Created by Noah Martin on 8/2/24.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

extension NSImage {
    public func pngData() -> NSData? {
        guard let tiffData = self.tiffRepresentation,
              let bitmapImageRep = NSBitmapImageRep(data: tiffData) else {
            return nil
        }

        let pngData = bitmapImageRep.representation(using: .png, properties: [:])
        return pngData as NSData?
    }
}
#endif
