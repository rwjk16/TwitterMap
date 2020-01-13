//
//  User.swift
//  TwitterLBTA
//
//  Created by Brian Voong on 1/9/17.
//  Copyright © 2017 Lets Build That App. All rights reserved.
//

import UIKit

struct User: Codable {
    let id: Int
    let name: String
    let screenName: String
    let profileImageUrlHttps: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.screenName = try container.decode(String.self, forKey: .screenName)
        self.profileImageUrlHttps = try container.decode(String.self, forKey: .profileImageUrlHttps)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.screenName, forKey: .screenName)
        try container.encode(self.profileImageUrlHttps, forKey: .profileImageUrlHttps)

    }
}


extension User {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case screenName = "screen_name"
        case profileImageUrlHttps = "profile_image_url_https"
    }
}
