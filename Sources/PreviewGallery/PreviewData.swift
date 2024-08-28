//
//  PreviewData.swift
//
//
//  Created by Noah Martin on 7/3/23.
//

import Foundation
import SnapshotPreviewsCore


/// A structure that manages a collection of preview types.
///
/// `PreviewData` is the backing data for PreviewGallery.
public struct PreviewData {
  /// The collection of preview types managed by this instance.
  let previews: [PreviewType]

  /// Initializes a new `PreviewData` instance with the given previews.
  ///
  /// - Parameter previews: An array of `PreviewType` instances to be managed by this `PreviewData`.
  public init(previews: [PreviewType]) {
    self.previews = previews
  }

  /// Retrieves and sorts the previews for a specific module.
  ///
  /// This method filters the previews to include only those from the specified module,
  /// then sorts them alphabetically by their type names.
  ///
  /// - Parameter module: The name of the module to filter previews for.
  /// - Returns: An array of `PreviewType` instances belonging to the specified module, sorted by type name.
  func previews(in module: String) -> [PreviewType] {
    previews.filter { $0.module == module }.sorted { $0.typeName < $1.typeName }
  }

  /// A set of all unique module names represented in the previews.
  var modules: Set<String> {
    Set(previews.map { $0.module })
  }

  /// A default instance of `PreviewData` that automatically finds all available previews.
  ///
  /// This property uses `FindPreviews.findPreviews()` to populate the previews.
  @MainActor public static var `default`: PreviewData {
    self.init(previews: FindPreviews.findPreviews())
  }
}
