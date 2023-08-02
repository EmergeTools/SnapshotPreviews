# 📸 SnapshotPreviews

An all-in-one iOS snapshot testing solution.

Emerge handles the heavy lifting of generating, diffing and hosting the snapshots for each build, allowing you to focus on building beautiful UI components.

## Features
 - Automatically generate snapshots of SwiftUI previews.
 - Support for color scheme/orientation.
 - Swift package for easy local validation.

## Generating Snapshots

See [the documentation](https://docs.emergetools.com/docs/swiftui-previews) for how to set up snapshot testing for your app.

## Local Debugging

Use this Swift Package for locally debugging your views snapshots. You’ll need a UI test target that imports the `SnapshottingTests` and `Snapshotting` products from this package. Create a test that inherits from `PreviewTest` like this:

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

Note there are no test functions. They get automatically added at runtime by `PreviewTest`. You can return a list of previews from the `snapshotPreviews()` function based on what preview you are trying to locally validate. The previews will be added as attachements in Xcode’s test results. The test must be run on an iOS simulator (not device).

![Screenshot of Xcode test output](images/testOutput.png)

See the demo app for a full example.
