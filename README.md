# 📸 SnapshotPreviews

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FEmergeTools%2FSnapshotPreviews-iOS%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/EmergeTools/SnapshotPreviews-iOS)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FEmergeTools%2FSnapshotPreviews-iOS%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/EmergeTools/SnapshotPreviews-iOS)


An all-in-one iOS snapshot testing solution built on Xcode previews. Automatic browsable gallery of previews, and no-code snapshot generation with XCTest. Supports SwiftUI and UIKit previews using `PreviewProvider` and `#Preview`.

# Installation

Add the package dependency to your Xcode project using the URL of this repository (https://github.com/EmergeTools/SnapshotPreviews-iOS). Link your app to `PreviewGallery` and (optionally) your XCTest target to `Snapshotting` and `SnapshottingTests`.

# Features

## Preview Gallery

`PreviewGallery` is an interactive UI built on top of snapshot extraction. It turns your Xcode previews into a gallery of components and features you can access from your application. Xcode is not required to view the previews. You can use it to preview individual components (buttons/rows/icons/etc) or even entire interactive features.

<p align="center">
  <img src="./images/image1.png" />
</p>

The public API of PreviewGallery is a single SwiftUI `View` named `PreviewGallery`. Displaying this view gives you access to the full gallery. For example, you could add a button with navigation like this:

```swift
import SwiftUI
import PreviewGallery

NavigationLink("Open Gallery") { PreviewGallery() }
```

The gallery also supports macOS. However, snapshotting does not support macOS.

## Local Snapshot Generation

The [EmergeTools snapshot testing service](https://docs.emergetools.com/docs/snapshot-testing) automatically handles hosting and diffing your snapshot tests. This Swift Package can be used for locally debugging the snapshots by generating images for each preview as part of a XCTest. You’ll need a UI test target that imports the `SnapshottingTests` and `Snapshotting` products from this package. Create a test that inherits from `PreviewTest` like this:

```
import Snapshotting
import SnapshottingTests

class MyPreviewTest: PreviewTest {

  override func getApp() -> XCUIApplication {
    return XCUIApplication()
  }

  override func snapshotPreviews() -> [String]? {
    return nil
  }
}
```

Note that there are no test functions; they are automatically added at runtime by `PreviewTest`. You can return a list of previews from the `snapshotPreviews()` function based on what preview you are trying to locally validate. The previews will be added as attachements in Xcode’s test results. The test must be run on an iOS simulator (not device).

> [!NOTE]
> When you use Preivew macros (`#Preview("Display Name")`) the name of the snapshot uses the file path and the name, for example: "MyModule/MyFile.swift:Display Name"

![Screenshot of Xcode test output](images/testOutput.png)

### Accessibility Audits

Xcode 15 [accessibility audits](https://developer.apple.com/documentation/xctest/xcuiapplication/4191487-performaccessibilityaudit) can also be run locally on any preview. By default they will use all audit types. To customize the behavior you can override the following functions in your test:

```
  override func enableAccessibilityAudit() -> Bool {
    true
  }

  @available(iOS 17.0, *)
  override func auditType() -> XCUIAccessibilityAuditType {
    return .all
  }

  @available(iOS 17.0, *)
  override func handle(_ issue: XCUIAccessibilityAuditIssue) -> Bool {
    return false
  }
```

See the demo app for a full example.

### Accessibility Snapshots

You can also add visualisations of accessibiilty elements to snapshots using the `emergeAccessibility` function. For example:

```
struct MyPreview: PreviewProvider {
  static var previews: some View {
    MyView()
      .emergeAccessibility(true)
  }
}
```
