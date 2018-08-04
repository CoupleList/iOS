//
//  EditActivityViewController.swift
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

protocol ActivityEditedDelegate: class {
    func activityWasEdited(_ activity: Activity)
}

class EditActivityViewController: UIViewController {
    
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
    
    
    let titleTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.font = UIFont.systemFont(ofSize: 30.0, weight: .medium)
        textView.textColor = .gray
        textView.returnKeyType = .next
        return textView
    }()
    
    let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.font = UIFont.systemFont(ofSize: 17.0, weight: .light)
        textView.textColor = .gray
        textView.returnKeyType = .done
        return textView
    }()
    
    let activityImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "ProfileImagePlaceholder")!
        return imageView
    }()
    
    let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.setTitle("Save", for: .normal)
        button.setTitleColor(UIColor.init(named: "MainColor"), for: .normal)
        button.addTarget(self, action: #selector(handleEdit), for: .touchUpInside)
        return button
    }()
    
    let completeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Complete", for: .normal)
        button.setTitleColor(UIColor.init(named: "MainColor"), for: .normal)
        button.addTarget(self, action: #selector(handleComplete), for: .touchUpInside)
        return button
    }()
    
    var ref: DatabaseReference!
    var storage: Storage!
    
    
    var delegate: ActivityEditedDelegate!
    var activity: Activity! {
        didSet {
            if let uid = activity.person {
                if let displayName = ActivitiesViewController.profileDisplayNames[uid] {
                    personLabel.text = "\(displayName) want\(displayName == "You" ? "" : "s") to"
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
            } else {
                activity.person = Auth.auth().currentUser!.uid
                personLabel.text = "You want to"
                
                if let profileImage = ActivitiesViewController.profileImages[activity.person!] {
                    profileImageView.image = profileImage
                } else {
                    let profileImageRef = self.storage.reference(withPath: "profileImages/\(activity.person!).JPG")
                    profileImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                        if error == nil {
                            let profileImage = UIImage(data: data!)!
                            self.profileImageView.image = profileImage
                            ActivitiesViewController.profileImages.updateValue(profileImage, forKey: self.activity.person!)
                        } else {
                            let profileImage = UIImage(named: "ProfileImagePlaceholder")!
                            self.profileImageView.image = profileImage
                            ActivitiesViewController.profileImages.updateValue(profileImage, forKey: self.activity.person!)
                        }
                    }
                }
            }
            
            titleTextView.text = activity.title
            descriptionTextView.text = activity.desc.isEmpty ? "Activity Description" : activity.desc
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(named: "MainColor")
        title = "Edit Activity"
        
        ref = Database.database().reference()
        storage = Storage.storage()
        
        setupView()
    }
    
    @objc func handleEdit() {
        view.endEditing(true)
        
        activity.title = titleTextView.text
        activity.desc = descriptionTextView.text
        
        ref.child("lists/\(AppDelegate.settings.listKey)/activities/\(activity.key)").updateChildValues(["title": activity.title, "description": activity.desc, "done": activity.isDone, "person": activity.person!, "lastEditor": Auth.auth().currentUser!.uid])
        
        delegate.activityWasEdited(activity)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleComplete() {
        print("completed")
        
        let alert = UIAlertController(title: "Complete Activity", message: "Completing \"\(activity.title)\" will signify progress made with your S.O, but, the activity will no longer be editable.", preferredStyle: .actionSheet)
        
        let completeAction = UIAlertAction(title: "Complete", style: .default, handler: {
            _ in
            self.activity.isDone = true
            
            self.ref.child("lists/\(AppDelegate.settings.listKey)/activities/\(self.activity.key)").updateChildValues(["title": self.activity.title, "description": self.activity.desc, "done": self.activity.isDone, "person": self.activity.person!, "lastEditor": Auth.auth().currentUser!.uid])
            
            self.delegate.activityWasEdited(self.activity)
            self.navigationController?.popViewController(animated: true)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(completeAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
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
        profileImageView.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        
        cardView.addSubview(personLabel)
        personLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10.0).isActive = true
        personLabel.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: -10.0).isActive = true
        personLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        
        cardView.addSubview(titleTextView)
        [
            titleTextView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 0.0),
            titleTextView.leftAnchor.constraint(equalTo: cardView.leftAnchor, constant: 5.0),
            titleTextView.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: -10.0),
            titleTextView.heightAnchor.constraint(equalToConstant: 52.0)
        ].forEach { $0.isActive = true }
        titleTextView.delegate = self
        textViewDidChange(titleTextView)
        
        cardView.addSubview(descriptionTextView)
        [
            descriptionTextView.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: 0.0),
            descriptionTextView.leftAnchor.constraint(equalTo: cardView.leftAnchor, constant: 5.0),
            descriptionTextView.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: -10.0),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 52.0)
        ].forEach { $0.isActive = true }
        descriptionTextView.delegate = self
        textViewDidChange(descriptionTextView)
        
        cardView.addSubview(saveButton)
        saveButton.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 0.0).isActive = true
        saveButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 0.0).isActive = true
        saveButton.leftAnchor.constraint(equalTo: cardView.leftAnchor, constant: 10.0).isActive = true
        
        cardView.addSubview(completeButton)
        completeButton.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 0.0).isActive = true
        completeButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 0.0).isActive = true
        completeButton.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: -10.0).isActive = true
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
}

extension EditActivityViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text! == (textView.font?.pointSize == 30.0 ? activity.title : activity.desc.isEmpty ? "Activity Description" : activity.desc) {
            textView.text = ""
            textView.textColor = UIColor.init(named: "MainColor")
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text! == "" {
            textView.text = textView.font?.pointSize == 30.0 ? activity.title : activity.desc.isEmpty ? "Activity Description" : activity.desc
            textView.textColor = .gray
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        saveButton.isEnabled = !titleTextView.text.isEmpty && (titleTextView.textColor != .gray || descriptionTextView.textColor != .gray)
        saveButton.setTitleColor(saveButton.isEnabled ? UIColor.init(named: "MainColor") : .lightGray, for: .normal)
        
        if textView.text.contains("\n") {
            textView.text = textView.text.replacingOccurrences(of: "\n", with: "")
            
            textView.resignFirstResponder()
            
            if textView.font?.pointSize == 30.0 {
                descriptionTextView.becomeFirstResponder()
            }
        }
        
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach {
            (constraint) in
            
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
                if estimatedSize.height > (textView.font?.pointSize == 30.0 ? 124 : 77.0) {
                    constraint.constant = textView.font?.pointSize == 30.0 ? 123.67: 77.0
                    textView.isScrollEnabled = true
                } else {
                    constraint.constant = estimatedSize.height
                    textView.isScrollEnabled = false
                }
            }
        }
    }
}
