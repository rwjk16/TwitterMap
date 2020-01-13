//
//  NetworkManager.swift
//  TwitterMap
//
//  Created by Russell Weber on 2020-01-11.
//  Copyright © 2020 Russell Weber. All rights reserved.
//

import Alamofire

class APIClient {
    private static let consumerKey = "FSblmcECKqrhaYogAwkbxQADR"
    private static let consumerSecret = "NuKb5n2CHva7QUafD9AuYmGXZxpdZuEDiYbc7AP78KlqTqofG4"
    private let accessToken = "1216133908984729601-H8myCUoymGdlbuWDMa0rdjEcFOVycN"
    private let secretAccessToken = "Jil3peiUr84ieDX9pmkjErUah8HlerIiYGlxqAyL2Y4Qz"
    private static let oAuthToken = "AAAAAAAAAAAAAAAAAAAAAN%2BTBwEAAAAAip1Lwho%2FET40DmdtoJlyaIF3QOw%3D1U63GBXoOZcZjx2TgjDLmCqqc4XnodU1ggJBMwd1hhL2wCHF3L"
    private static let headers = ["Authorization": "Bearer \(oAuthToken)"]
    private static var params = ["query": "geocode",
    ]
    
    private static let today = Date()
    private static let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: today)!
    
    static func getTweetsFrom(long: Double, lat: Double, radius: Double, completion: @escaping(Result<Response, AFError>) -> ()) {
        let jsonDecoder = JSONDecoder()
        let dateFormatter = DateFormatter.tweetDateFormatter
        let toDate = dateFormatter.string(from: today)
        let fromDate = dateFormatter.string(from: thirtyDaysAgo)
        params["query"] = "point_radius:[\(long) \(lat) \(radius)km]"
        params["toDate"] = toDate
        params["fromDate"] = fromDate
        print("query: \("\(long),\(lat),\(radius)km")")
        jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.tweetDateFormatter)
        AF.request("https://api.twitter.com/1.1/tweets/search/30day/dev.json", method: .get, parameters: params, encoding: URLEncoding.default, headers: HTTPHeaders.init(APIClient.headers), interceptor: nil).responseDecodable (decoder: jsonDecoder){ (response: AFDataResponse<Response>) in
            //            print("Response: \(response)")
            DispatchQueue.main.async {
                print("RESULt: \(response.result)")
                completion(response.result)
            }
        }
    }
}

extension DateFormatter {
    static var tweetDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmm"
        return formatter
    }
}
