//
//  TweetAnnotation.swift
//  TwitterMap
//
//  Created by Russell Weber on 2020-01-12.
//  Copyright © 2020 Russell Weber. All rights reserved.
//

import UIKit
import MapKit

class TweetAnnotation: NSObject, MKAnnotation {
  let title: String?
  let text: String
  let coordinate: CLLocationCoordinate2D

  init(title: String, text: String, discipline: String, coordinate: CLLocationCoordinate2D) {
    self.title = title
    self.text = text
    self.coordinate = coordinate

    super.init()
  }


  var subtitle: String? {
    return text
  }

  // pinTintColor for disciplines: Sculpture, Plaque, Mural, Monument, other
    var markerTintColor: UIColor  = .blue

  var imageName: String? {
    return "Flag"
  }

}

class TweetMarkerView: MKMarkerAnnotationView {

  override var annotation: MKAnnotation? {
    willSet {
      guard let artwork = newValue as? TweetAnnotation else { return }
      canShowCallout = true
      calloutOffset = CGPoint(x: -5, y: 5)
      rightCalloutAccessoryView = UIButton(type: .detailDisclosure)

      markerTintColor = artwork.markerTintColor
//      glyphText = String(artwork.discipline.first!)
        if let imageName = artwork.imageName {
          glyphImage = UIImage(named: imageName)
        } else {
          glyphImage = nil
      }
    }
  }

}
