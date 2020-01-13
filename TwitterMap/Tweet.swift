//
//  Tweet.swift
//  TwitterLBTA
//
//  Created by Brian Voong on 1/24/17.
//  Copyright © 2017 Lets Build That App. All rights reserved.
//

import Foundation

struct Tweet: Codable {
    let id: Int
    let text: String
    let user: User
    let geocode: Location?
    
    let createdAt: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.text = try container.decode(String.self, forKey: .text)
        self.user = try container.decode(User.self, forKey: .user)
        self.geocode = try container.decodeIfPresent(Location.self, forKey: .geocode)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var statuses = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .statuses)
        try statuses.encode(self.id, forKey: .id)
        try statuses.encode(self.text, forKey: .text)
        try statuses.encode(self.user, forKey: .user)
        try statuses.encode(self.geocode, forKey: .geocode)
        try statuses.encode(self.createdAt, forKey: .createdAt)
        
    }
}

extension Tweet {
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case user
        case geocode = "place"
        case createdAt = "created_at"
        case statuses
    
    }
}

struct Location: Codable {
    let long: Double
    let lat: Double
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let place = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .boundingBox)
        var coordinates = try place.nestedUnkeyedContainer(forKey: .coordinates)
        var first = try coordinates.nestedUnkeyedContainer()
        var second = try first.nestedUnkeyedContainer()
        self.lat = try second.decode(Double.self)
        self.long = try second.decode(Double.self)
    }
    
    func encode(to encoder: Encoder) throws {
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



