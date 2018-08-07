//
//  ActivityTableViewCell.swift
//  Couple List
//
//  Created by Kirin Patel on 7/6/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseAnalytics
import FirebaseDatabase

class ActivityTableViewCell: UITableViewCell {
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20.0
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let personLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = UIColor.init(named: "MainColor")
        label.font = UIFont.systemFont(ofSize: 20.0, weight: .light)
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = UIColor.init(named: "MainColor")
        label.font = UIFont.systemFont(ofSize: 30.0, weight: .medium)
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = UIColor.init(named: "MainColor")
        label.font = UIFont.systemFont(ofSize: 17.0, weight: .light)
        return label
    }()
    
    let doneIndicator: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.init(named: "AppleGreen")
        label.text = " "
        label.layer.cornerRadius = 5.0
        label.layer.masksToBounds = true
        label.isHidden = true
        return label
    }()
    
    let activityImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    lazy var widthConstraint = profileImageView.widthAnchor.constraint(equalToConstant: 40.0)
    lazy var heightConstraint = profileImageView.heightAnchor.constraint(equalToConstant: 40.0)
    
    var activity: Activity! {
        didSet {
            if let person = activity.person {
                if let displayName = ActivitiesTableViewController.profileDisplayNames[person] {
                    if activity.isDone {
                        personLabel.text = "\(displayName) and \(displayName == "You" ? "your S.O." : "you")"
                    } else {
                        personLabel.text = "\(displayName) want\(displayName == "You" ? "" : "s") to"
                    }
                } else {
                    personLabel.text = ""
                }
                
                if let profileImage = ActivitiesTableViewController.profileImages[person] {
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
            doneIndicator.isHidden = !activity.isDone
            
            if let image = activity.image {
                activityImageView.image = image
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.init(named: "MainColor")
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupView() {
        contentView.addSubview(cardView)
        cardView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 0.0).isActive = true
        cardView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -8.0).isActive = true
        cardView.leftAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leftAnchor, constant: 0.0).isActive = true
        cardView.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor, constant: 0.0).isActive = true
        
        cardView.addSubview(profileImageView)
        profileImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10.0).isActive = true
        profileImageView.leftAnchor.constraint(equalTo: cardView.leftAnchor, constant: 10.0).isActive = true
        
        cardView.addSubview(personLabel)
        personLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10.0).isActive = true
        personLabel.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: -10.0).isActive = true
        personLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        
        cardView.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10.0).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: cardView.leftAnchor, constant: 10.0).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: -10.0).isActive = true
        
        cardView.addSubview(descriptionLabel)
        descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4.0).isActive = true
        descriptionLabel.leftAnchor.constraint(equalTo: cardView.leftAnchor, constant: 10.0).isActive = true
        descriptionLabel.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: -10.0).isActive = true
        
        cardView.addSubview(doneIndicator)
        doneIndicator.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 4.0).isActive = true
        doneIndicator.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -10.0).isActive = true
        doneIndicator.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: -10.0).isActive = true
        doneIndicator.widthAnchor.constraint(equalToConstant: 10.0).isActive = true
        doneIndicator.heightAnchor.constraint(equalToConstant: 10.0).isActive = true
    }
}
