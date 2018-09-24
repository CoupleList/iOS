//
//  CLCard.swift
//  Couple List
//
//  Created by Kirin Patel on 8/6/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import MapKit

protocol CLCardDelegate: class {
    func getDirectionsForActivity(placemark: CLPlacemark)
}

class CLCard: UIView {
    
    fileprivate let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    fileprivate let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    fileprivate let personLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = UIColor.init(named: "MainColor")
        label.font = UIFont.systemFont(ofSize: 20, weight: .light)
        return label
    }()
    
    fileprivate let richContentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        return stackView
    }()
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = UIColor.init(named: "MainColor")
        label.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        return label
    }()
    
    fileprivate let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = UIColor.init(named: "MainColor")
        label.font = UIFont.systemFont(ofSize: 24, weight: .light)
        return label
    }()
    
    fileprivate let activityImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "profilePicture")!
        return imageView
    }()
    
    let bottomView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    internal lazy var widthConstraint = profileImageView.widthAnchor.constraint(equalToConstant: 40.0)
    internal lazy var heightConstraint = profileImageView.heightAnchor.constraint(equalToConstant: 40.0)
    internal lazy var richContentHeightConstraint = richContentStackView.heightAnchor.constraint(equalToConstant: UIDevice.current.userInterfaceIdiom == .pad ? 350 : 200)
    
    var activity: Activity! {
        didSet {
            if let person = activity.person {
                if let displayName = CL.shared.profileDisplayNames[person] {
                    if activity.isDone {
                        personLabel.text = "\(displayName) and \(displayName == "You" ? "your S.O." : "you")"
                    } else {
                        personLabel.text = "\(displayName) want\(displayName == "You" ? "" : "s") to"
                    }
                } else {
                    personLabel.text = ""
                }
                
                if let profileImage = CL.shared.profileImages[person] {
                    profileImageView.image = profileImage
                    widthConstraint.isActive = true
                    heightConstraint.isActive = true
                    cardView.setNeedsLayout()
                }
            } else {
                personLabel.text = ""
                profileImageView.image = nil
                widthConstraint.isActive = false
                heightConstraint.isActive = false
                cardView.setNeedsLayout()
            }
            
            titleLabel.text = activity.title
            descriptionLabel.text = activity.desc
            
            if let image = activity.image {
                activityImageView.image = image
            } else if let location = activity.location {
                setupMapView(location: location)
            } else {
                richContentStackView.arrangedSubviews.forEach { richContentStackView.removeArrangedSubview($0) }
                richContentHeightConstraint.isActive = false
            }
        }
    }
    var activityLocation: CLPlacemark?
    var delegate: CLCardDelegate?

    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleGetDirections() {
        if let delegate = delegate {
            if let placemark = activityLocation {
                delegate.getDirectionsForActivity(placemark: placemark)
            }
        }
    }
    
    fileprivate func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.init(named: "MainColor")
        
        addSubview(cardView)
        cardView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        cardView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        cardView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        cardView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        
        cardView.addSubview(profileImageView)
        profileImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10).isActive = true
        profileImageView.leftAnchor.constraint(equalTo: cardView.leftAnchor, constant: 10).isActive = true
        
        cardView.addSubview(personLabel)
        personLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10).isActive = true
        personLabel.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: -10).isActive = true
        personLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        
        cardView.addSubview(richContentStackView)
        richContentStackView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10).isActive = true
        richContentStackView.leftAnchor.constraint(equalTo: cardView.leftAnchor, constant: 0).isActive = true
        richContentStackView.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: 0).isActive = true
        
        cardView.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: richContentStackView.bottomAnchor, constant: 0).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: cardView.leftAnchor, constant: 10).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: -10).isActive = true
        
        cardView.addSubview(descriptionLabel)
        descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0).isActive = true
        descriptionLabel.leftAnchor.constraint(equalTo: cardView.leftAnchor, constant: 10).isActive = true
        descriptionLabel.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: -10).isActive = true
        
        cardView.addSubview(bottomView)
        bottomView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 0).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 0).isActive = true
        bottomView.leftAnchor.constraint(equalTo: cardView.leftAnchor, constant: 0).isActive = true
        bottomView.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: 0).isActive = true
    }
    
    fileprivate func setupMapView(location: MKPlacemark) {
        richContentStackView.arrangedSubviews.forEach { richContentStackView.removeArrangedSubview($0) }
        richContentHeightConstraint.isActive = true
        let mapView = MKMapView()
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        mapView.isPitchEnabled = false
        mapView.isRotateEnabled = false
        getLocation(location: CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)) { annotation in
            mapView.addAnnotation(annotation)
        }
        let span = MKCoordinateSpanMake(0.015, 0.015)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        mapView.setRegion(region, animated: true)
        mapView.delegate = self
        richContentStackView.addArrangedSubview(mapView)
    }
    
    fileprivate func getLocation(location: CLLocation, _ completion: @escaping (_ annotation: MKPointAnnotation) -> Void) {
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let _ = error { return }
            
            guard let placemark = placemarks?.first else { return }
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            annotation.title = placemark.name
            if let city = placemark.locality, let state = placemark.administrativeArea {
                annotation.subtitle = "\(city) \(state)"
            }
            
            self.activityLocation = placemark
            completion(annotation)
        }
    }
}

extension CLCard: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
        pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.markerTintColor = UIColor.init(named: "MainColor")
        pinView?.animatesWhenAdded = true
        pinView?.canShowCallout = true
        let getDirectionsButton = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
        getDirectionsButton.setBackgroundImage(UIImage.init(named: "GetDirections"), for: .normal)
        getDirectionsButton.addTarget(self, action: #selector(handleGetDirections), for: .touchUpInside)
        pinView?.rightCalloutAccessoryView = getDirectionsButton
        return pinView
    }
}
