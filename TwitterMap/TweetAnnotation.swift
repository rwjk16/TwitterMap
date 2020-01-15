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
      let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero,
        size: CGSize(width: 30, height: 30)))
//        mapsButton.setBackgroundImage(UIImage(named: "Maps-icon"), for: UIControl.State())
      rightCalloutAccessoryView = mapsButton
//      rightCalloutAccessoryView = UIButton(type: .detailDisclosure)

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

  init(title: String, text: String, coordinate: CLLocationCoordinate2D) {
    self.title = title
    self.text = text
    self.coordinate = coordinate

    super.init()
  }
    
    init?(tweet: Tweet) {
        self.title = tweet.user.screenName
        self.text = tweet.text
        
        if let long = tweet.geocode?.long, let lat = tweet.geocode?.lat {
            self.coordinate = CLLocationCoordinate2DMake(lat, long)
        } else {
            self.coordinate = CLLocationCoordinate2D()
        }
    }


  var subtitle: String? {
    return text
  }

  // pinTintColor for disciplines: Sculpture, Plaque, Mural, Monument, other
    var markerTintColor: UIColor  = .blue

  var imageName: String? {
    return "Flag"
  }

  // Annotation right callout accessory opens this mapItem in Maps app
  func mapItem() -> MKMapItem {
//    let addressDict = [CNPostalAddressStreetKey: subtitle!]
    let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: [:])
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.name = title
    return mapItem
  }

}
