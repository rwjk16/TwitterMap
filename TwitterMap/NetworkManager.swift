//
//  NetworkManager.swift
//  TwitterMap
//
//  Created by Russell Weber on 2020-01-11.
//  Copyright © 2020 Russell Weber. All rights reserved.
//

import Alamofire
import TwitterKit

class APIClient {
    private static let oAuthToken = "AAAAAAAAAAAAAAAAAAAAAN%2BTBwEAAAAAip1Lwho%2FET40DmdtoJlyaIF3QOw%3D1U63GBXoOZcZjx2TgjDLmCqqc4XnodU1ggJBMwd1hhL2wCHF3L"
    private static let headers = ["Authorization": "Bearer \(oAuthToken)"]
    private static var params = ["q":""]
    
    public static var fetchedTweets = [Tweet]()
    
    public static let client = TWTRAPIClient()
    
    private static let today = Date()
    private static let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: today)!
    
    static func getTweetsFrom(long: Double, lat: Double, radius: Double, completion: @escaping(Result<Response, AFError>) -> ()) {
        let jsonDecoder = JSONDecoder()
        params.removeAll()
        params["q"] = ""
        params["tweet_mode"] = "extended"
        params["geocode"] = "\(lat),\(long),\(radius)km"
        params["count"] = "100"
        print("query: \("\(lat),\(long),\(radius)km")")
        DispatchQueue.global(qos: .background).async {
            AF.request("https://api.twitter.com/1.1/search/tweets.json", method: .get, parameters: params, encoding: URLEncoding.default, headers: HTTPHeaders.init(APIClient.headers), interceptor: nil).responseDecodable (decoder: jsonDecoder){ (response: AFDataResponse<Response>) in
                print("RESULT: \(response)")
                DispatchQueue.main.async {
                    completion(response.result)
                }
            }
        }
    }
    
    static func search(for string: String, lang: String,  completion: @escaping(Result<Response, AFError>) -> ()) {
        let jsonDecoder = JSONDecoder()
        params.removeAll()
        params["q"] = string
        params["tweet_mode"] = "extended"
        params["lang"] = lang
        DispatchQueue.global(qos: .background).async {
            AF.request("https://api.twitter.com/1.1/search/tweets.json", method: .get, parameters: params, encoding: URLEncoding.default, headers: HTTPHeaders.init(APIClient.headers), interceptor: nil).responseDecodable (decoder: jsonDecoder){ (response: AFDataResponse<Response>) in
                print("RESULT: \(response)")
                DispatchQueue.main.async {
                    completion(response.result)
                }
            }
        }
    }
    
    static func downloadImage(for url: URL, completion: @escaping(Result<Data, AFError>)->()) {
        DispatchQueue.global(qos: .background).async {
            AF.download(url).responseData { (response) in
                completion(response.result)
            }
        }
    }
}
