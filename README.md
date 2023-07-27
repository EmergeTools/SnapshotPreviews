# PreviewGallery

`PreviewGallery` turns your SwiftUI previews into a gallery of compoents and features you can access from your application. With one line of code
all your previews are accessible to anyone using the app, Xcode is not required. You can use it to preview individual components (buttons/rows/icons/etc)
or even entire interactive features. With `PreviewGallery` you write your previews exactly as you would to view them in Xcode, and they are automatically
added to the gallery where they can be shared with other members of your team for faster feature development.

## Features

- Automatic setup, every `#Preview` and `PreviewProvider` are included.
- View all previews in a scroll view to easily spot the component you’re looking for.
- Organization by module
- Multiple variant support for `PreviewProvider`. The first variant is shown in the module’s list, and you can select the preview to expand individual variants.
- Modifiers:
 - `displayName`: Overrides the name shown in the gallery
 - `colorScheme`/`prefererdColorScheme`: Overrides the color scheme shown in the gallery
 - **Coming Soon** `previewLayout`: Specify `device` for full-screen previews
- Filter unnecessary previews such as from 3rd party code

## Installing

The public API of PreviewGallery is just one SwiftUI `View`: `PreviewGallery.GalleryView`. Just display this view to get the fully gallery. For example, you could add a button like this:

```swift
import SwiftUI
import PreviewGallery

NavigationLink("Open Gallery") { GalleryView() }
```

Note that it only makes sense to show the gallery if there are previews in your app, for example a release build wouldn’t link to `PreviewGallery` at all.
You can also make your entire app a `GalleryView`:

```swift
import SwiftUI
import PreviewGallery

@main
struct DemoAppApp: App {
    var body: some Scene {
        WindowGroup {
            GalleryView()
        }
    }
}
```

This is useful if you have many previews that you don't want to include in your developer app, and instead use a separate app just for the gallery.

## Crashing Views

If previews crash when creating the `View` the gallery will also crash. A common occurance is forgetting to inject SwiftUI Environment objects into your views before returning them from a `PreviewProvider`. Using snapshot tests will ensure these bugs don't actually make it into your codebase and break the gallery.

## Testing

Emerge automatically supports running snapshot tests for any view that is part of the gallery. For debugging purposes, you can also generate pngs locally using the target `SnapshotPreview`. Just link this to an XCUITest and call `generateSnapshots(XCUIApplication())`. This can be useful for fast debugging of any rendering issues in your snapshots.