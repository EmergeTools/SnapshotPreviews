#PreviewsSupport

This exposes functions in UIKit and SwiftUI for extracting previews that are not in the swiftinterface for these libraries. The symbols are in the .tbd files, and can be found at link-time.

Modifications to the libraries are needed to make the Swift compiler see these symbols, which is why this is built outside of SPM and linked to the main snapshots package as a binaryTarget.

To build locally, modify `Xcode.app/Contents/Developer/Platforms/[iPhoneSimulator/iPhoneOS].platform/Developer/SDKs/iPhoneSimulator.sdk/System/Library/Frameworks/SwiftUI.framework/Modules/SwiftUI.swiftmodule/*.swiftinterface` with the following additions at the end of the files:

```
@available(iOS 17.0, *)
public struct ViewPreviewSource {
  public var makeView: @_Concurrency.MainActor () -> any SwiftUI.View
}
```

and modify `Xcode.app/Contents/Developer/Platforms/[iPhoneSimulator/iPhoneOS].platform/Developer/SDKs/iPhoneSimulator.sdk/System/Library/Frameworks/UIKit.framework/Modules/UIKit.swiftmodule/*.swiftinterface` with the following additions at the end of the files:

```
@available(iOS 17.0, *)
public struct UIViewPreviewSource {
  public var makeView: @_Concurrency.MainActor () -> UIKit.UIView
}

@available(iOS 17.0, *)
public struct UIViewControllerPreviewSource {
  public var makeViewController: @_Concurrency.MainActor () -> UIKit.UIViewController
}
```
