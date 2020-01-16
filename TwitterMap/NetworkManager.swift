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
    
    public static var twtrTweets = [TWTRTweet]()
    
    public static var currentUser: TweetUser?
    
    public static var client = TWTRAPIClient()
    
    static func getTweetsFrom(long: Double, lat: Double, radius: Double, completion: @escaping(Result<Response, AFError>) -> ()) {
        let jsonDecoder = TwitterDecoder.jsonDecoder
        params.removeAll()
        params["q"] = ""
        params["tweet_mode"] = "extended"
        params["geocode"] = "\(lat),\(long),\(radius)km"
        params["count"] = "100"
        print("query: \("\(lat),\(long),\(radius)km")")
        DispatchQueue.global(qos: .background).async {
            AF.request("https://api.twitter.com/1.1/search/tweets.json", method: .get, parameters: params, encoding: URLEncoding.default, headers: HTTPHeaders.init(APIClient.headers), interceptor: nil).responseDecodable (decoder: jsonDecoder){ (response: AFDataResponse<Response>) in
                DispatchQueue.main.async {
                    completion(response.result)
                }
            }
        }
    }
    
    static func search(for string: String, lang: String,  completion: @escaping(Result<Response, AFError>) -> ()) {
        let jsonDecoder = TwitterDecoder.jsonDecoder
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
    
    static func login(with viewController: UIViewController) {
        TWTRTwitter.sharedInstance().logIn(with: viewController) { (session, error) in
            if (session != nil) {
                print("signed in as \(String(describing: session?.userName))");
                
                viewController.dismiss(animated: true) {
                    print("Logged in ")
                }
                self.client = TWTRAPIClient.withCurrentUser()
            } else {
                print("error: \(error?.localizedDescription ?? "")");
            }
        }
    }
    
    static func fetchTWTRTweets(tweets: [Tweet]) {
        DispatchQueue.global(qos: .background).async {
            self.client.loadTweets(withIDs: tweets.map({ (tweet) -> String in
                return String(tweet.id)
            })) { (tweets, error) in
                if let tweets = tweets {
                    self.twtrTweets = tweets
                } else {
                    print(error!)
                }
            }
        }
    }
}
