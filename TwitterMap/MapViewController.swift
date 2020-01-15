//
//  ViewController.swift
//  TwitterMap
//
//  Created by Russell Weber on 2020-01-11.
//  Copyright © 2020 Russell Weber. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate{
    
    var annotations = [MKAnnotation]()
    
    let locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation = CLLocation()
    
    let refreshButton: RefreshButton = RefreshButton()
    let dockToggle: Button = Button()
    let centerButton : Button = Button()
    
    var dockToggled = false
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startMonitoringSignificantLocationChanges()
        self.mapView.delegate = self
        
        setupViews()
        fetchTweets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.isHidden = true
    }
    
    func fetchTweets(){
        locationManager.startUpdatingLocation()
        let radius = 5.0
        guard let currentPosition = locationManager.location?.coordinate else { return }
        DispatchQueue.global(qos: .background).async {
            print("CURRETN LOCATION: \(self.currentLocation)")
            APIClient.getTweetsFrom(long: currentPosition.longitude, lat: currentPosition.latitude, radius: radius, completion: { (result) in
                switch result {
                case .success(let response):
                    APIClient.fetchedTweets = response.tweets
                    for tweet in response.tweets {
                        guard let location = tweet.geocode else { continue }
                        let anno = location.long != 0.0 ? TweetAnnotationObject(title: tweet.user.screenName, text: tweet.text, coordinate: CLLocationCoordinate2DMake(location.long, location.lat)) : TweetAnnotationObject(title: tweet.user.screenName, text: tweet.text, coordinate: self.generateRandomCoordinates(min: 0, max: UInt32(radius)))
                        print(anno.coordinate)
                        self.annotations.append(anno)
                    }
                    
                    DispatchQueue.main.async {
                        print("\(self.annotations.count)")
                        self.mapView.addAnnotations(self.annotations)
                        self.mapView.showAnnotations(self.mapView.annotations, animated: true)
                        print(self.mapView.annotations.last!.coordinate)
                        self.locationManager.stopUpdatingLocation()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            })
        }
    }
    
    //spoofs tweet location to display on map, with 30day endpoint all tweets are returned with location so this isnt necesarry
    
    func generateRandomCoordinates(min: UInt32, max: UInt32)-> CLLocationCoordinate2D {
        //Get the Current Location's longitude and latitude
        let currentLong = currentLocation.coordinate.longitude
        let currentLat = currentLocation.coordinate.latitude

        let kmCoord = 0.00900900900901

        let randomMeters = UInt(arc4random_uniform(max) + min)

        let randomPM = arc4random_uniform(6)

        let metersCordN = kmCoord * Double(randomMeters)

        if randomPM == 0 {
            return CLLocationCoordinate2D(latitude: currentLat + metersCordN, longitude: currentLong + metersCordN)
        }else if randomPM == 1 {
            return CLLocationCoordinate2D(latitude: currentLat - metersCordN, longitude: currentLong - metersCordN)
        }else if randomPM == 2 {
            return CLLocationCoordinate2D(latitude: currentLat + metersCordN, longitude: currentLong - metersCordN)
        }else if randomPM == 3 {
            return CLLocationCoordinate2D(latitude: currentLat - metersCordN, longitude: currentLong + metersCordN)
        }else if randomPM == 4 {
            return CLLocationCoordinate2D(latitude: currentLat, longitude: currentLong - metersCordN)
        }else {
            return CLLocationCoordinate2D(latitude: currentLat - metersCordN, longitude: currentLong)
        }

    }
    
    func setupViews(){
        setupButtonImages()
        positionButtons()
    }
    
    //MARK: Buttons
    func positionButtons(){
        positionRefreshButton()
        positionDockToggleButton()
        positionCenterButton()
    }
    
    func positionRefreshButton() {
        let x = self.view.frame.maxX * 0.90
        let y = self.view.frame.maxY * 0.77
        refreshButton.center = CGPoint(x: x, y: y)
    }
    
    func positionDockToggleButton() {
        let x = self.view.frame.maxX * 0.90
        let y = self.view.frame.maxY * 0.85
        dockToggle.center = CGPoint(x: x, y: y)
    }
    
    func positionCenterButton(){
        let x = self.view.frame.maxX * 0.10
        let y = self.view.frame.maxY * 0.85
        centerButton.center = CGPoint(x: x, y: y)
    }
    
    func setupButtonImages() {
        self.view.insertSubview(refreshButton, aboveSubview: self.mapView)
        self.view.insertSubview(dockToggle, aboveSubview: self.mapView)
        self.view.insertSubview(centerButton, aboveSubview: self.mapView)
        
        if let image = UIImage(named: "refresh") {
            refreshButton.setImage(image, for: .normal)
        }
        refreshButton.addTarget(self, action: #selector(refreshButtonPressed), for: .touchUpInside)
        dockToggle.addTarget(self, action: #selector(dockToggleButtonPressed), for: .touchUpInside)
        centerButton.setImage(UIImage(named: "compass"), for: .normal)
        centerButton.addTarget(self, action: #selector(handleCenter), for: .touchUpInside)
    }
    
    @objc func refreshButtonPressed() {
        refreshButton.rotateImage()
        fetchTweets()
    }
    
    @objc func dockToggleButtonPressed() {
        self.dockToggled = !self.dockToggled
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotations(self.annotations)
    }

    //MARK: Setup Region
    
    func setupRegion() {
        let lat = 0.01
        let lng = 0.01
        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: lat, longitudeDelta: lng)
        let region: MKCoordinateRegion = MKCoordinateRegion(center: self.currentLocation.coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
    }
    
    func addAnnotation(long: Double, lat: Double){
        let CLLCoordType = CLLocationCoordinate2D(latitude: lat,
                                                  longitude: long);
        let anno = MKPointAnnotation();
        anno.coordinate = CLLCoordType;
        mapView.addAnnotation(anno);
    }
    
    //MARK: CLLocationDelegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.first {
            self.currentLocation = currentLocation
        }
        self.mapView.showsUserLocation = true
        setupRegion()
    }
    
    @objc func handleCenter(){
        locationManager.startUpdatingLocation()
        mapView.centerCoordinate = currentLocation.coordinate
        setupRegion()
        locationManager.stopUpdatingLocation()
    }
}

extension MapViewController:MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
      guard let annotation = annotation as? TweetAnnotationObject else { return nil }
      let identifier = "marker"
      var view: TweetView
      if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        as? TweetView {
        dequeuedView.annotation = annotation
        view = dequeuedView
      } else {
        view = TweetView(annotation: annotation, reuseIdentifier: identifier)
        view.canShowCallout = true
        view.calloutOffset = CGPoint(x: -5, y: 5)
        view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
      }
      return view
    }

}
