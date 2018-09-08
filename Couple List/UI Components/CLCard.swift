//
//  CLCard.swift
//  Couple List
//
//  Created by Kirin Patel on 8/6/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import MapKit

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
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.textColor = UIColor.init(named: "MainColor")
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        return label
    }()
    
    fileprivate let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = UIColor.init(named: "MainColor")
        label.font = UIFont.systemFont(ofSize: 18, weight: .light)
        return label
    }()
    
    fileprivate let activityImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "ProfileImagePlaceholder")!
        return imageView
    }()
    
    let bottomView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    internal lazy var profileImageWidthConstraint = profileImageView.widthAnchor.constraint(equalToConstant: 40)
    internal lazy var profileImageHeightConstraint = profileImageView.heightAnchor.constraint(equalToConstant: 40)
    internal lazy var richContentHeightConstraint = richContentStackView.heightAnchor.constraint(equalToConstant: 150)
    
    var activity: Activity! {
        didSet {
            if let person = activity.person {
                if let profileImage = CL.shared.profileImages[person] {
                    profileImageView.image = profileImage
                    profileImageWidthConstraint.isActive = true
                    profileImageHeightConstraint.isActive = true
                    cardView.setNeedsLayout()
                }
            } else {
                profileImageView.image = nil
                profileImageWidthConstraint.isActive = false
                profileImageHeightConstraint.isActive = false
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

    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        cardView.addSubview(richContentStackView)
        richContentStackView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10).isActive = true
        richContentStackView.leftAnchor.constraint(equalTo: cardView.leftAnchor, constant: 0).isActive = true
        richContentStackView.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: 0).isActive = true
        
        cardView.addSubview(titleLabel)
        titleLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: -10).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        
        cardView.addSubview(descriptionLabel)
        descriptionLabel.topAnchor.constraint(equalTo: richContentStackView.bottomAnchor, constant: 0).isActive = true
        descriptionLabel.leftAnchor.constraint(equalTo: cardView.leftAnchor, constant: 10).isActive = true
        descriptionLabel.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: -10).isActive = true
        
        cardView.addSubview(bottomView)
        bottomView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 0).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -10).isActive = true
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
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        if let name = location.name {
            annotation.title = name
        } else {
            annotation.title = "Activity Location"
        }
        if let city = location.locality, let state = location.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        } else {
            annotation.subtitle = activity.title
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.015, 0.015)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        mapView.setRegion(region, animated: true)
        mapView.delegate = self
        richContentStackView.addArrangedSubview(mapView)
    }
}

extension CLCard: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let location = activity.location {
            let mapItem = MKMapItem(placemark: location)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
}
