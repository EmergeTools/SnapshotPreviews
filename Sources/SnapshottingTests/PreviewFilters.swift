//
//  PreviewFilters.swift
//
//
//  Created by Noah Martin on 8/9/24.
//

import Foundation

public protocol PreviewFilters {
  /// Override to return a list of previews that should be snapshotted. The default is null, which snapshots all previews.
  /// Elements should be the type name of the preview, like "MyModule.MyView_Previews". This also supports Regex format.
  ///
  /// Override this method to specify which previews should be included in the snapshot test.
  /// - Returns: An optional array of String containing the names of previews to be included.
  static func snapshotPreviews() -> [String]?

  /// Override to return a list of previews that should NOT be snapshotted. The default is null, which excludes none.
  /// Elements should be the type name of the preview, like "MyModule.MyView_Previews". This also supports Regex format.
  ///
  /// Override this method to specify which previews should be excluded from the snapshot test.
  /// - Returns: An optional array of String containing the names of previews to be excluded.
  static func excludedSnapshotPreviews() -> [String]?

  /// Override to return a list of module names that should be snapshotted.
  /// Elements should be exact module names from the type name prefix, e.g. "MyModule" for "MyModule.MyView_Previews".
  static func snapshotPreviewModules() -> [String]?

  /// Override to return a list of module names that should NOT be snapshotted.
  /// Elements should be exact module names from the type name prefix, e.g. "MyModule" for "MyModule.MyView_Previews".
  static func excludedSnapshotPreviewModules() -> [String]?
}
