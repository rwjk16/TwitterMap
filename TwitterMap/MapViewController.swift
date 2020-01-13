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
    var tweets = [Tweet]()
    
    //  var stationStatus = [stationStatusStruct]()
    let locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation = CLLocation()
    //  var stationSelected : Station?
    //  let manager = StationManager()
    
    let refreshButton: RefreshButton = RefreshButton()
    let favoritesButton: Button = Button()
    let dockToggle: Button = Button()
    let backButton: Button = Button()
    let centerButton : Button = Button()
    
    var dockToggled = false
    
    //  let stationDetailView = StationDetailModalView()
    
    let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        return mapView
    }()
    
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        mapView.addGestureRecognizer(tapGesture)
    }
    
    func fetchTweets(){
        DispatchQueue.global(qos: .background).async {
            self.locationManager.startUpdatingLocation()
            print("CURRETN LOCATION: \(self.currentLocation)")
            APIClient.getTweetsFrom(long: self.currentLocation.coordinate.longitude, lat: self.currentLocation.coordinate.latitude, radius: 10, completion: { (result) in
                switch result {
                case .success(let response):
                    self.tweets = response.tweets
                    for tweet in self.tweets {
                        guard let location = tweet.geocode else { continue }
                        print("TWEET GEOCODE: \(tweet.geocode)")
                        let anno = MKPointAnnotation()
                        anno.coordinate = CLLocationCoordinate2DMake(location.long, location.lat)
                        self.annotations.append(anno)
                    }
                    
                    DispatchQueue.main.async {
                        print("\(self.annotations.count)")
                        self.mapView.addAnnotations(self.annotations)
                        self.mapView.showAnnotations(self.mapView.annotations, animated: true)
                        print(self.mapView.annotations.count)
                        self.locationManager.stopUpdatingLocation()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            })
        }
    }
    
    
    func setupViews(){
        constrainMapView()
        setupButtonImages()
        positionButtons()
        //    setupStationView()
    }
    
    //MARK: Buttons
    func positionButtons(){
        positionRefreshButton()
        positionFavoritesButton()
        positionDockToggleButton()
        positionBackButton()
        positionCenterButton()
    }
    
    
    func positionFavoritesButton() {
        let x = self.view.frame.maxX * 0.90
        let y = self.view.frame.maxY * 0.82
        favoritesButton.center = CGPoint(x: x, y: y)
    }
    
    func positionRefreshButton() {
        let x = self.view.frame.maxX * 0.90
        let y = self.view.frame.maxY * 0.74
        refreshButton.center = CGPoint(x: x, y: y)
    }
    
    func positionDockToggleButton() {
        let x = self.view.frame.maxX * 0.90
        let y = self.view.frame.maxY * 0.90
        dockToggle.center = CGPoint(x: x, y: y)
    }
    
    func positionBackButton() {
        let x = self.view.frame.maxX * 0.10
        let y = self.view.frame.maxY * 0.10
        backButton.center = CGPoint(x: x, y: y)
    }
    
    func positionCenterButton(){
        let x = self.view.frame.maxX * 0.10
        let y = self.view.frame.maxY * 0.90
        centerButton.center = CGPoint(x: x, y: y)
    }
    
    func setupButtonImages() {
        self.view.insertSubview(refreshButton, aboveSubview: self.mapView)
        self.view.insertSubview(favoritesButton, aboveSubview: self.mapView)
        self.view.insertSubview(dockToggle, aboveSubview: self.mapView)
        self.view.insertSubview(backButton, aboveSubview: self.mapView)
        self.view.insertSubview(centerButton, aboveSubview: self.mapView)
        
        if let image = UIImage(named: "refresh") {
            refreshButton.setImage(image, for: .normal)
        }
        refreshButton.addTarget(self, action: #selector(refreshButtonPressed), for: .touchUpInside)
        if let image = UIImage(named: "favorites") {
            favoritesButton.setImage(image, for: .normal)
        }
        favoritesButton.addTarget(self, action: #selector(favoritesButtonPressed), for: .touchUpInside)
        if let image = UIImage(named: "dockToggle") {
            dockToggle.setImage(image, for: .normal)
        }
        dockToggle.addTarget(self, action: #selector(dockToggleButtonPressed), for: .touchUpInside)
        if let image = UIImage(named: "back") {
            backButton.setImage(image, for: .normal)
        }
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        centerButton.setImage(UIImage(named: "compass"), for: .normal)
        centerButton.addTarget(self, action: #selector(handleCenter), for: .touchUpInside)
    }
    
    @objc func refreshButtonPressed() {
        refreshButton.rotateImage()
        fetchTweets()
    }
    
    
    
    @objc func favoritesButtonPressed() {
        //    let favoritesView = FavoritesViewController()
        //    favoritesView.favoriteStations = self.favoriteStations as! [Station]
        //    self.navigationController?.pushViewController(favoritesView, animated: true)
    }
    
    @objc func dockToggleButtonPressed() {
        self.dockToggled = !self.dockToggled
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotations(self.annotations)
    }
    
    @objc func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Setup Region & constrain mapview
    func constrainMapView() {
        view.addSubview(mapView)
        mapView.center = self.view.center
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        mapView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
    }
    
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
    
    @objc func handleTap(){
        //    stationDetailView.isHidden = true
    }
    
    @objc func handleFav(){
        //    SVProgressHUD.show(withStatus: "Saving Fav")
        //    Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (nil) in
        //      SVProgressHUD.dismiss()
        //
        //      for station in self.stations {
        //        for (i, favoritedStation) in self.favoriteStations.enumerated() {
        //          if favoritedStation.title == self.stationDetailView.stationNameLabel.text {
        //            self.favoriteStations.remove(at: i)
        //            return
        //          }
        //        }
        //
        //        if let title = station.title {
        //          if title == self.stationDetailView.stationNameLabel.text {
        //            self.favoriteStations.append(station)
        //            return
        //          }
        //        }
        //      }
        //    }
    }
    
    @objc func handleDirection(){
        //    guard let coordinate = stationSelected?.coordinate else {return}
        //    let regionDistance = 1000.0
        //    let regionSpan = MKCoordinateRegion(center: coordinate,latitudinalMeters: regionDistance,longitudinalMeters: regionDistance)
        //    let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)]
        //
        //    let placeMark = MKPlacemark(coordinate: coordinate)
        //    let mapItem = MKMapItem(placemark: placeMark)
        //    mapItem.name = stationSelected?.address
        //    mapItem.openInMaps(launchOptions: options)
    }
    
    @objc func handleCenter(){
        locationManager.startUpdatingLocation()
        mapView.centerCoordinate = currentLocation.coordinate
        setupRegion()
        locationManager.stopUpdatingLocation()
    }
}

extension MapViewController:MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //    var numBikes = ""
        //    var numDocks = ""
        //    if let annotation = view.annotation as? Station{
        //      self.stationSelected = annotation
        //      let id = annotation.station_id
        //      for station in self.stationStatus{
        //        if station.station_id == id{
        //          numBikes = String(station.num_bikes_available)
        //          numDocks = String(station.num_docks_available)
        //        }
        //      }
        //      let bikesText = NSMutableAttributedString(string: numBikes, attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 35)])
        //      bikesText.append(NSAttributedString(string: "\nBikes", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor : UIColor.lightGray]))
        //
        //      let docksText = NSMutableAttributedString(string: numDocks, attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 35)])
        //      docksText.append(NSAttributedString(string: "\nDocks", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor : UIColor.lightGray]))
        //
        //      if view.annotation is MKUserLocation{
        //        return
        //      }
        //
        //      self.stationDetailView.numOfBikesLabel.attributedText = bikesText
        //      self.stationDetailView.numOfDocksLabel.attributedText = docksText
        ////      self.stationDetailView.stationNameLabel.text = annotation.name
        //    }
        //
        //    UIView.transition(with: stationDetailView, duration: 0.3, options: .transitionCrossDissolve, animations: {
        //      self.stationDetailView.isHidden = false
        //    }, completion: nil)
    }

}
