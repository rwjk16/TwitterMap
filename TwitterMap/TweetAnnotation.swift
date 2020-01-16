//
//  TweetAnnotation.swift
//  TwitterMap
//
//  Created by Russell Weber on 2020-01-12.
//  Copyright © 2020 Russell Weber. All rights reserved.
//

import UIKit
import MapKit

class TweetView: MKAnnotationView {
    
    override var annotation: MKAnnotation? {
        willSet {
            guard let tweet = newValue as? TweetAnnotationObject else {return}
            
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
            image = UIImage(named: "Flag")
            
            let detailLabel = UILabel()
            detailLabel.numberOfLines = 0
            detailLabel.font = detailLabel.font.withSize(12)
            detailLabel.text = tweet.text
            detailCalloutAccessoryView = detailLabel
        }
    }
}

class TweetAnnotationObject: NSObject, MKAnnotation {
    let title: String?
    let text: String
    let coordinate: CLLocationCoordinate2D
    let tweetID: Int
    
    init(title: String, text: String, coordinate: CLLocationCoordinate2D, id: Int) {
        self.title = title
        self.text = text
        self.coordinate = coordinate
        self.tweetID = id
        
        super.init()
    }
    
    init?(tweet: Tweet) {
        self.title = tweet.user.screenName
        self.text = tweet.fullText
        self.tweetID = tweet.id
        
        if let long = tweet.geocode?.long, let lat = tweet.geocode?.lat {
            self.coordinate = CLLocationCoordinate2DMake(lat, long)
        } else {
            self.coordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        }
    }
    
    
    var subtitle: String? {
        return text
    }
    
    var markerTintColor: UIColor  = .blue
    
    var imageName: String? {
        return "Flag"
    }
    
}
