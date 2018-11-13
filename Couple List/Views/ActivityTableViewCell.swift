//
//  ActivityTableViewCell.swift
//  Couple List
//
//  Created by Kirin Patel on 7/6/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth
import FirebaseAnalytics
import FirebaseDatabase

protocol ActivityTableViewCellDelegate: class {
    func getDirectionsForActivity(placemark: CLPlacemark)
}

class ActivityTableViewCell: UITableViewCell {
    
    let clCard = CLCard()
    
    let doneIndicator: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.init(named: "AppleGreen")
        label.text = " "
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        return label
    }()
    
    var activity: Activity! {
        didSet {
            clCard.activity = activity
            if activity.isDone {
                clCard.bottomView.addSubview(doneIndicator)
                doneIndicator.topAnchor.constraint(equalTo: clCard.bottomView.topAnchor, constant: 10).isActive = true
                doneIndicator.bottomAnchor.constraint(equalTo: clCard.bottomView.bottomAnchor, constant: 0).isActive = true
                doneIndicator.rightAnchor.constraint(equalTo: clCard.bottomView.rightAnchor, constant: -10).isActive = true
                doneIndicator.widthAnchor.constraint(equalToConstant: 10).isActive = true
                doneIndicator.heightAnchor.constraint(equalToConstant: 10).isActive = true
            }
        }
    }
    var delegate: ActivityTableViewCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.init(named: "MainColor")
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupView() {
        contentView.addSubview(clCard)
        clCard.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        clCard.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -8).isActive = true
        clCard.leftAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        clCard.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        clCard.delegate = self
        
        clCard.bottomView.addSubview(doneIndicator)
        doneIndicator.topAnchor.constraint(equalTo: clCard.bottomView.topAnchor, constant: 4).isActive = true
        doneIndicator.bottomAnchor.constraint(equalTo: clCard.bottomView.bottomAnchor, constant: -10).isActive = true
        doneIndicator.rightAnchor.constraint(equalTo: clCard.bottomView.rightAnchor, constant: -10).isActive = true
        doneIndicator.widthAnchor.constraint(equalToConstant: 10).isActive = true
        doneIndicator.heightAnchor.constraint(equalToConstant: 10).isActive = true
    }
}

extension ActivityTableViewCell: CLCardDelegate {
    
    func getDirectionsForActivity(placemark: CLPlacemark) {
        if let delegate = delegate {
            delegate.getDirectionsForActivity(placemark: placemark)
        }
    }
}
