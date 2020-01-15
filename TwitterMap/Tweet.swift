//
//  Tweet.swift
//  TwitterMap
//
//  Created by Russell Weber on 2020-01-14.
//  Copyright © 2020 Russell Weber. All rights reserved.
//

import Foundation

struct Tweet: Codable, Hashable {
    
    enum Language: String {
        case en
        case fr
        case all
    }
    
    let id: Int
    let text: String
    let user: User
    let geocode: Location?
    let lang: String
    let mediaURL: String?
    var retweeted: Bool
    var liked: Bool
        
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.text = try container.decode(String.self, forKey: .text)
        self.user = try container.decode(User.self, forKey: .user)
        self.lang = try container.decode(String.self, forKey: .lang)
        self.geocode = try container.decodeIfPresent(Location.self, forKey: .geocode) ?? Location()
        self.retweeted = try container.decode(Bool.self, forKey: .retweeted)
        self.liked = try container.decode(Bool.self, forKey: .liked)
        
        
        let entities = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .entities)
        if let media = try? entities.nestedContainer(keyedBy: CodingKeys.self, forKey: .media) {
            self.mediaURL = try media.d
            
        } else {
            self.mediaURL = nil
        }
    }
    
    
    static func == (lhs: Tweet, rhs: Tweet) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var statuses = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .statuses)
        try statuses.encode(self.id, forKey: .id)
        try statuses.encode(self.text, forKey: .text)
        try statuses.encode(self.user, forKey: .user)
        try statuses.encode(self.geocode, forKey: .geocode)
        try statuses.encode(self.lang, forKey: .lang)
        try statuses.encode(self.liked, forKey: .liked)
        try statuses.encode(self.retweeted, forKey: .retweeted)

    }
}

extension Tweet {
    enum CodingKeys: String, CodingKey {
        case id
        case text = "full_text"
        case user
        case geocode = "place"
        case statuses
        case lang
        case liked = "favorited"
        case retweeted
        case entities = "extended_entities"
        case mediaURL = "media_url"
        case media
    
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
    
    init() {
        self.long = 0.0
        self.lat = 0.0
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



