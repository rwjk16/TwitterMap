//
//  Location.swift
//  TwitterMap
//
//  Created by Russell Weber on 2020-01-15.
//  Copyright © 2020 Russell Weber. All rights reserved.
//

import Foundation

public struct Location: Codable {
    let long: Double
    let lat: Double
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let place = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .boundingBox)
        var coordinates = try place.nestedUnkeyedContainer(forKey: .coordinates)
        var first = try coordinates.nestedUnkeyedContainer()
        var second = try first.nestedUnkeyedContainer()
        self.lat = try second.decode(Double.self)
        self.long = try second.decode(Double.self)
    }
    
    init() {
        self.long = 0.0
        self.lat = 0.0
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var coordinates = container.nestedUnkeyedContainer(forKey: .coordinates)
        try coordinates.encode(self.lat)
        try coordinates.encode(self.long)
        
    }
}

extension Location {
    enum CodingKeys: String, CodingKey {
        case coordinates
        case boundingBox = "bounding_box"
    }
}
