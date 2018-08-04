//
//  ViewActivityViewController.swift
//  Couple List
//
//  Created by Kirin Patel on 7/7/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseAnalytics
import FirebaseDatabase
import FirebaseStorage

class ActivityViewController: UIViewController {
    
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
    
    let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
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
        label.font = UIFont.systemFont(ofSize: 24.0, weight: .light)
        return label
    }()
    
    let activityImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "ProfileImagePlaceholder")!
        return imageView
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Delete", for: .normal)
        button.tintColor = UIColor.init(named: "AppleRed")
        button.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
        return button
    }()
    
    let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Edit", for: .normal)
        button.addTarget(self, action: #selector(handleEdit), for: .touchUpInside)
        return button
    }()
    
    var ref: DatabaseReference!
    var storage: Storage!
    
    var activity: Activity! {
        didSet {
            if let uid = activity.person {
                if let displayName = ActivitiesViewController.profileDisplayNames[uid] {
                    if activity.isDone {
                        personLabel.text = "\(displayName) and \(displayName == "You" ? "your S.O." : "you")"
                    } else {
                        personLabel.text = "\(displayName) want\(displayName == "You" ? "" : "s") to"
                    }
                }
                
                if let profileImage = ActivitiesViewController.profileImages[uid] {
                    profileImageView.image = profileImage
                } else {
                    let profileImageRef = self.storage.reference(withPath: "profileImages/\(uid).JPG")
                    profileImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                        if error == nil {
                            let profileImage = UIImage(data: data!)!
                            self.profileImageView.image = profileImage
                            ActivitiesViewController.profileImages.updateValue(profileImage, forKey: uid)
                        } else {
                            let profileImage = UIImage(named: "ProfileImagePlaceholder")!
                            self.profileImageView.image = profileImage
                            ActivitiesViewController.profileImages.updateValue(profileImage, forKey: uid)
                        }
                    }
                }
                
                profileImageView.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
                profileImageView.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
            }
            
            titleLabel.text = activity.title
            descriptionLabel.text = activity.desc
            editButton.isEnabled = !activity.isDone
            editButton.setTitleColor(editButton.isEnabled ? UIColor.init(named: "MainColor") : .gray, for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(named: "MainColor")
        title = "Activity Details"
        
        ref = Database.database().reference()
        
        setupView()
    }
    
    @objc func handleDelete() {
        let alert = UIAlertController(title: "Delete Activity?", message: "Deleting this activity means that you and your S.O. can no longer track progress for it. This is a destructive process and is not reversable.", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete Activity", style: .destructive, handler: {
            _ in
            self.ref.child("lists/\(AppDelegate.settings.listKey)/activities/\(self.activity.key)").removeValue()
            self.navigationController!.popViewController(animated: true)
        })
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func handleEdit() {
        let editActivityViewController = EditActivityViewController()
        editActivityViewController.activity = activity
        editActivityViewController.delegate = self
        navigationController?.pushViewController(editActivityViewController, animated: true)
    }
    
    fileprivate func setupView() {
        view.addSubview(cardView)
        cardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0.0).isActive = true
        cardView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0.0).isActive = true
        cardView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0.0).isActive = true
        cardView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        
        cardView.addSubview(profileImageView)
        profileImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10.0).isActive = true
        profileImageView.leftAnchor.constraint(equalTo: cardView.leftAnchor, constant: 10.0).isActive = true
        
        cardView.addSubview(personLabel)
        personLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10.0).isActive = true
        personLabel.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: -10.0).isActive = true
        personLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        
        cardView.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 0.0).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: cardView.leftAnchor, constant: 10.0).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: -10.0).isActive = true
        
        cardView.addSubview(descriptionLabel)
        descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0.0).isActive = true
        descriptionLabel.leftAnchor.constraint(equalTo: cardView.leftAnchor, constant: 10.0).isActive = true
        descriptionLabel.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: -10.0).isActive = true
        
        cardView.addSubview(editButton)
        editButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 0.0).isActive = true
        editButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 0.0).isActive = true
        editButton.leftAnchor.constraint(equalTo: cardView.leftAnchor, constant: 10.0).isActive = true
        
        cardView.addSubview(deleteButton)
        deleteButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 0.0).isActive = true
        deleteButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 0.0).isActive = true
        deleteButton.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: -10.0).isActive = true
    }
}

extension ActivityViewController: ActivityEditedDelegate {
    
    func activityWasEdited(_ activity: Activity) {
        self.activity = activity
    }
}
