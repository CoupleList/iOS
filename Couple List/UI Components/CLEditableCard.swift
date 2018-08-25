//
//  CLEditableCard.swift
//  Couple List
//
//  Created by Kirin Patel on 8/24/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class CLEditableCard: UIView {
    
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
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        cardView.addSubview(personLabel)
        personLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10).isActive = true
        personLabel.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: -10).isActive = true
        personLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        
        cardView.addSubview(titleTextView)
        titleTextView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 0).isActive = true
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
