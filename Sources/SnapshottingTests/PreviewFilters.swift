//
//  PreviewFilters.swift
//
//
//  Created by Noah Martin on 8/9/24.
//

import Foundation

public protocol PreviewFilters {
  // Override to return a list of previews that should be snapshotted.
  // The default is null, which snapshots all previews.
  // Elements should be the type name of the preview, like "MyModule.MyView_Previews"
  func snapshotPreviews() -> [String]?

  func excludedSnapshotPreviews() -> [String]?
}
