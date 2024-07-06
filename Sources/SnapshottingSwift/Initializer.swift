//
//  File.swift
//  
//
//  Created by Noah Martin on 7/12/23.
//

import Foundation
import UIKit

@objc
public class Initializer: NSObject {

  @objc
  static public let shared = Initializer()

  let snapshots = Snapshots()

}
