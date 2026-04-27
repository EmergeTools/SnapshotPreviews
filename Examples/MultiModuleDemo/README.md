# MultiModuleDemo

A small iOS Xcode project used to validate module-level filtering for snapshot preview discovery.

The host app links several framework targets that each contribute SwiftUI previews. Without filtering, a single `SnapshotTest` bundle would discover previews from every linked module. This demo exercises the `snapshotPreviewModules()` / `excludedSnapshotPreviewModules()` overrides to confirm previews can be scoped to specific modules.

## Running

Open `MultiModuleDemo.xcodeproj` in Xcode and run the tests with **Product › Test** (⌘U), or from the command line:

```bash
TEST_RUNNER_SNAPSHOTS_EXPORT_DIR=/tmp/snapshots xcodebuild test \
  -scheme MultiModuleDemo \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  -skip-testing:MultiModuleDemoTests/ModuleFilterAssertionTests \
  CODE_SIGNING_ALLOWED=NO \
  | xcpretty
```
