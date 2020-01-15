//
//  AppDelegate.swift
//  TwitterMap
//
//  Created by Russell Weber on 2020-01-11.
//  Copyright © 2020 Russell Weber. All rights reserved.
//

import UIKit
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        TWTRTwitter.sharedInstance().start(withConsumerKey: "FSblmcECKqrhaYogAwkbxQADR", consumerSecret: "NuKb5n2CHva7QUafD9AuYmGXZxpdZuEDiYbc7AP78KlqTqofG4")
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let directedByTWTR =  TWTRTwitter.sharedInstance().application(app, open: url, options: options)
        return directedByTWTR
    }
    
}

