//
//  AddActivityViewController.swift
//  Couple List
//
//  Created by Kirin Patel on 7/4/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseAnalytics
import FirebaseDatabase
import FirebaseStorage

class AddActivityViewController: UIViewController {
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20.0
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "ProfileImagePlaceholder")!
        return imageView
    }()
    
    let personLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.text = "You want to"
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
        textView.text = "Activity Title"
        textView.font = UIFont.systemFont(ofSize: 30.0, weight: .medium)
        textView.textColor = .gray
        textView.returnKeyType = .next
        return textView
    }()
    
    let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.text = "Activity Description"
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
    
    let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.setTitle("Add", for: .normal)
        button.setTitleColor(UIColor.init(named: "MainColor"), for: .normal)
        button.addTarget(self, action: #selector(handleAdd), for: .touchUpInside)
        return button
    }()
    
    var ref: DatabaseReference!
    var storage: Storage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(named: "MainColor")
        title = "Add Activity"
        
        ref = Database.database().reference()
        storage = Storage.storage()
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let uid = Auth.auth().currentUser!.uid
        
        if let profileImage = ActivitiesTableViewController.profileImages[uid] {
            profileImageView.image = profileImage
        } else {
            let profileImageRef = self.storage.reference(withPath: "profileImages/\(uid).JPG")
            profileImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if error == nil {
                    let profileImage = UIImage(data: data!)!
                    self.profileImageView.image = profileImage
                    ActivitiesTableViewController.profileImages.updateValue(profileImage, forKey: uid)
                }
            }
        }
    }
    
    @objc func handleAdd() {
        view.endEditing(true)
        
        let key = ref.child("lists/\(AppDelegate.settings.listKey)/activities").childByAutoId().key
        let title = titleTextView.text!
        let desc = descriptionTextView.text! == "Activity Description" ? "" : descriptionTextView.text!
        
        ref.child("lists/\(AppDelegate.settings.listKey)/activities/\(key)").setValue(["title": title, "description": desc, "done": false, "person": Auth.auth().currentUser!.uid])
        
        navigationController?.popViewController(animated: true)
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
            titleTextView.leftAnchor.constraint(equalTo: cardView.leftAnchor, constant: 0.0),
            titleTextView.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: 0.0),
            titleTextView.heightAnchor.constraint(equalToConstant: 52.0)
        ].forEach { $0.isActive = true }
        titleTextView.delegate = self
        textViewDidChange(titleTextView)
        
        cardView.addSubview(descriptionTextView)
        [
            descriptionTextView.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: 0.0),
            descriptionTextView.leftAnchor.constraint(equalTo: cardView.leftAnchor, constant: 0.0),
            descriptionTextView.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: 0.0),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 52.0)
            ].forEach { $0.isActive = true }
        descriptionTextView.delegate = self
        textViewDidChange(descriptionTextView)
        
        cardView.addSubview(addButton)
        addButton.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 0.0).isActive = true
        addButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 0.0).isActive = true
        addButton.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: -4.0).isActive = true

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
}

extension AddActivityViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text! == (textView.font?.pointSize == 30.0 ? "Activity Title" : "Activity Description") {
            textView.text = ""
            textView.textColor = UIColor.init(named: "MainColor")
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text! == "" {
            textView.text = textView.font?.pointSize == 30.0 ? "Activity Title" : "Activity Description"
            textView.textColor = .gray
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        addButton.isEnabled = !titleTextView.text.isEmpty && titleTextView.textColor != .gray
        addButton.setTitleColor(addButton.isEnabled ? UIColor.init(named: "MainColor") : .lightGray, for: .normal)
        
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
