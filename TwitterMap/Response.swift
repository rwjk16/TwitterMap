//
//  Response.swift
//  TwitterMap
//
//  Created by Russell Weber on 2020-01-12.
//  Copyright © 2020 Russell Weber. All rights reserved.
//

import Foundation

struct Response: Codable {
    let tweets: [Tweet]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.tweets = try container.decode([Tweet].self, forKey: .tweets)
    }
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.tweets, forKey: .tweets)
    }
}


extension Response {
    enum CodingKeys: String, CodingKey {
        case tweets = "statuses"
    }
}
