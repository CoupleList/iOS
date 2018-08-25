//
//  MapKitLocationFinder.swift
//  Couple List
//
//  Created by Kirin Patel on 8/24/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import MapKit
import GoogleMobileAds

protocol HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark)
}

class MapKitLocationFinder: UIViewController {
    
    let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsUserLocation = true
        return mapView
    }()
    
    var bannerView: GADBannerView!
    
    var clEditableCardDelegate: CLEditableCardDelegate? = nil
    var selectedPin: MKPlacemark? = nil
    var searchResultController: UISearchController!
    let locationManager = CLLocationManager()
    let locationTableViewContoller = LocationTableViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(named: "MainColor")
        title = "Add Location"
        definesPresentationContext = true
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        setupView()
    }
    
    @objc func setActivityLocation() {
        if let name = selectedPin?.name {
            let action = UIAlertController(title: "Set Activity Location?", message: "Would you like to set the activity's location to \(name)?", preferredStyle: .alert)
            
            let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
                self.clEditableCardDelegate?.userAddedLocation(location: self.selectedPin!)
                self.navigationController?.popViewController(animated: true)
            }
            let cancelAction = UIAlertAction(title: "No", style: .cancel)
            action.addAction(yesAction)
            action.addAction(cancelAction)
            
            present(action, animated: true)
        }
    }
    
    fileprivate func setupView() {
        searchResultController = UISearchController(searchResultsController: locationTableViewContoller)
        searchResultController.searchResultsUpdater = locationTableViewContoller
        searchResultController.hidesNavigationBarDuringPresentation = false
        searchResultController.dimsBackgroundDuringPresentation = true
        searchResultController.searchBar.sizeToFit()
        searchResultController.searchBar.barStyle = .black
        searchResultController.searchBar.placeholder = "Search for places..."
        searchResultController.searchBar.delegate = self
        navigationItem.titleView = searchResultController.searchBar
        locationTableViewContoller.mapView = mapView
        locationTableViewContoller.handleMapSearchDelegate = self
        
        if CL.shared.noAds() {
            view.addSubview(mapView)
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
            mapView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
            mapView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
            mapView.delegate = self
        } else {
            bannerView = GADBannerView(adSize: kGADAdSizeBanner)
            bannerView.adUnitID = "ca-app-pub-9026572937829340/4827317247"
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            bannerView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(bannerView)
            bannerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
            bannerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
            bannerView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
            
            view.addSubview(mapView)
            mapView.topAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: 0).isActive = true
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
            mapView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
            mapView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
            mapView.delegate = self
        }
    }
}

extension MapKitLocationFinder: CLLocationManagerDelegate {
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        navigationController?.popViewController(animated: true)
    }
}

extension MapKitLocationFinder: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        locationTableViewContoller.updateSearchResults(for: searchResultController)
    }
}

extension MapKitLocationFinder: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
        pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.animatesWhenAdded = true
        pinView?.canShowCallout = true
        let btn = UIButton(type: .contactAdd)
        btn.addTarget(self, action: #selector(setActivityLocation), for: .touchUpInside)
        pinView?.rightCalloutAccessoryView = btn
        return pinView
    }
}

extension MapKitLocationFinder: HandleMapSearch {
    
    func dropPinZoomIn(placemark: MKPlacemark) {
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality, let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.015, 0.015)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
}
