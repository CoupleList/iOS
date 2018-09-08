//
//  CLEditableCard.swift
//  Couple List
//
//  Created by Kirin Patel on 8/24/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

protocol CLEditableCardDelegate: class {
    func userWantsToAddLocation()
    func userWantsToChangeLocation()
    func userWantsToRemoveLocation()
    func userAddedLocation(location: MKPlacemark)
}

class CLEditableCard: UIView {
    
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
        imageView.image = UIImage(named: "ProfileImagePlaceholder")!
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
    
    fileprivate let titleTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        textView.textColor = .gray
        textView.returnKeyType = .next
        return textView
    }()
    
    fileprivate let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.font = UIFont.systemFont(ofSize: 17, weight: .light)
        textView.textColor = .gray
        textView.returnKeyType = .done
        return textView
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
    
    fileprivate let addImageContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage.init(named: "ActivityAddImage")!
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .clear
        view.addSubview(imageView)
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        return view
    }()
    
    fileprivate let addLocationContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage.init(named: "ActivityAddLocation")!
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .clear
        view.addSubview(imageView)
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        return view
    }()
    
    let bottomView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    var delegate: CLEditableCardDelegate?
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
                    cardView.setNeedsLayout()
                }
            } else {
                personLabel.text = ""
                profileImageView.image = UIImage.init(named: "ProfileImagePlaceholder")
                cardView.setNeedsLayout()
            }
            
            titleTextView.text = activity.title
            descriptionTextView.text = activity.desc.isEmpty ? "Activity Description" : activity.desc
            
            if let image = activity.image {
                richContentStackView.arrangedSubviews.forEach { richContentStackView.removeArrangedSubview($0) }
            } else if let location = activity.location {
                setupMapView(location: location)
            } else {
                resetRichContent()
            }
        }
    }
    var activityLocation: CLPlacemark?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleSelectLocation() {
        if let delegate = delegate {
            guard activity.location == nil else { return }
            delegate.userWantsToAddLocation()
        }
    }
    
    @objc func handleChangeLocation() {
        if let delegate = delegate {
            delegate.userWantsToChangeLocation()
        }
    }
    
    @objc func handleRemoveLocation() {
        if let delegate = delegate {
            delegate.userWantsToRemoveLocation()
        }
    }
    
    fileprivate func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = true
        backgroundColor = UIColor.init(named: "MainColor")
        
        addSubview(cardView)
        cardView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        cardView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        cardView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        cardView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        
        cardView.addSubview(profileImageView)
        profileImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10).isActive = true
        profileImageView.leftAnchor.constraint(equalTo: cardView.leftAnchor, constant: 10).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        cardView.addSubview(personLabel)
        personLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10).isActive = true
        personLabel.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: -10).isActive = true
        personLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        
        addLocationContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectLocation)))
        
        cardView.addSubview(richContentStackView)
        richContentStackView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10).isActive = true
        richContentStackView.leftAnchor.constraint(equalTo: cardView.leftAnchor, constant: 0).isActive = true
        richContentStackView.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: 0).isActive = true
        richContentStackView.heightAnchor.constraint(equalToConstant: UIDevice.current.userInterfaceIdiom == .pad ? 350 : 200).isActive = true
        
        cardView.addSubview(titleTextView)
        titleTextView.topAnchor.constraint(equalTo: richContentStackView.bottomAnchor, constant: 0).isActive = true
        titleTextView.leftAnchor.constraint(equalTo: cardView.leftAnchor, constant: 5).isActive = true
        titleTextView.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: -10).isActive = true
        titleTextView.delegate = self
        
        cardView.addSubview(descriptionTextView)
        descriptionTextView.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: 0).isActive = true
        descriptionTextView.leftAnchor.constraint(equalTo: cardView.leftAnchor, constant: 5).isActive = true
        descriptionTextView.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: -10).isActive = true
        descriptionTextView.delegate = self
        
        cardView.addSubview(bottomView)
        bottomView.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 0).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 0).isActive = true
        bottomView.leftAnchor.constraint(equalTo: cardView.leftAnchor, constant: 0).isActive = true
        bottomView.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: 0).isActive = true
    }
    
    fileprivate func setupMapView(location: MKPlacemark) {
        richContentStackView.arrangedSubviews.forEach { richContentStackView.removeArrangedSubview($0) }
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
    
    fileprivate func resetRichContent() {
        richContentStackView.arrangedSubviews.forEach { richContentStackView.removeArrangedSubview($0) }
//        richContentStackView.addArrangedSubview(addImageContainer)
        richContentStackView.addArrangedSubview(addLocationContainer)
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

extension CLEditableCard: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text! == (textView == titleTextView ? activity.title : activity.desc.isEmpty ? "Activity Description" : activity.desc) {
            textView.text = ""
            textView.textColor = UIColor.init(named: "MainColor")
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if textView.text! == "" {
            textView.text = textView.font?.pointSize == 30 ? activity.title : activity.desc.isEmpty ? "Activity Description" : activity.desc
            textView.textColor = .gray
        } else {
            if textView == titleTextView {
                activity.title = titleTextView.text
            } else {
                activity.desc = descriptionTextView.text
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.contains("\n") {
            textView.resignFirstResponder()
            
            if textView == titleTextView {
                descriptionTextView.becomeFirstResponder()
            }
        } else {
            if textView == titleTextView {
                activity.title = titleTextView.text
            } else {
                activity.desc = descriptionTextView.text
            }
        }
    }
}

extension CLEditableCard: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
        pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.markerTintColor = UIColor.init(named: "MainColor")
        pinView?.animatesWhenAdded = true
        pinView?.canShowCallout = true
        let changeDirectionsButton = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
        changeDirectionsButton.setBackgroundImage(UIImage.init(named: "ChangeDirections"), for: .normal)
        changeDirectionsButton.addTarget(self, action: #selector(handleChangeLocation), for: .touchUpInside)
        let removeDirectionsButton = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
        removeDirectionsButton.setBackgroundImage(UIImage.init(named: "RemoveDirections"), for: .normal)
        removeDirectionsButton.addTarget(self, action: #selector(handleRemoveLocation), for: .touchUpInside)
        let stackView = UIStackView(frame: CGRect(origin: .zero, size: CGSize(width: 68, height: 30)))
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.addArrangedSubview(changeDirectionsButton)
        stackView.addArrangedSubview(removeDirectionsButton)
        pinView?.rightCalloutAccessoryView = stackView
        return pinView
    }
}
