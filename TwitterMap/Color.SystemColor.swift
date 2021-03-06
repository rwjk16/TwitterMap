//
//  Color.SystemColor.swift
//  advanced-swift-codable
//
//  Created by Leo Dion on 2/13/19.
//  Copyright © 2019 Leo Dion. All rights reserved.
//

import Foundation

#if os(iOS) || os(watchOS) || os(tvOS)
import UIKit
public typealias SystemColor = UIColor
#elseif os(macOS)
public typealias SystemColor = NSColor
#endif

extension Color {  
  public var systemColor : SystemColor {
    return SystemColor(red: self.red, green: self.green, blue: self.blue, alpha: self.alpha)
  }
}
