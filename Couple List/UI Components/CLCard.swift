//
//  CLCard.swift
//  Couple List
//
//  Created by Kirin Patel on 8/6/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit

class CLCard: UIView {
    
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
    
    fileprivate let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
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
        imageView.image = UIImage(named: "ProfileImagePlaceholder")!
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
        
        cardView.addSubview(personLabel)
        personLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10).isActive = true
        personLabel.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: -10).isActive = true
        personLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        
        cardView.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 0).isActive = true
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
}
