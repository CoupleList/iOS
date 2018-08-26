//
//  SetListViewController.swift
//  Couple List
//
//  Created by Kirin Patel on 8/25/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SetListViewController: UIViewController {
    
    let titleLabel = CLTitleLabel(text: "Getting Started")
    
    fileprivate let createImageContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage.init(named: "SetListCreate")!
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .clear
        view.addSubview(imageView)
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        let titleLabel = CLDescriptionLabel(text: "Create List")
        view.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 15).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        return view
    }()
    
    fileprivate let joinImageContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage.init(named: "SetListJoin")!
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .clear
        view.addSubview(imageView)
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        let titleLabel = CLDescriptionLabel(text: "Join List")
        view.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 15).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        return view
    }()
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(named: "MainColor")
        
        ref = Database.database().reference()
        
        setupView()
    }
    
    @objc func handleCreateList() {
        let listKey = ref.child("user/\(Auth.auth().currentUser!.uid)").childByAutoId().key
        let listCode = ref.child("user/\(Auth.auth().currentUser!.uid)/list").childByAutoId().key
        
        CL.shared.userSettings.listKey = listKey
        CL.shared.userSettings.listCode = listCode
        
        ref.child("users/\(Auth.auth().currentUser!.uid)/list").setValue([
            "key": CL.shared.userSettings.listKey,
            "code": CL.shared.userSettings.listCode
            ], withCompletionBlock: { (error, snapshot) in
                guard error == nil else { return }
                self.ref.child("lists/\(listKey)/code").setValue(listCode, withCompletionBlock: { (error, snapshot) in
                    guard error == nil else { return }
                    self.dismiss(animated: true)
                })
            })
    }
    
    @objc func handleJoinList() {
        
    }
    
    fileprivate func setupView() {
        createImageContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCreateList)))
        joinImageContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleJoinList)))
        
        let startingStackView = UIStackView(arrangedSubviews: [createImageContainer, joinImageContainer])
        startingStackView.translatesAutoresizingMaskIntoConstraints = false
        startingStackView.axis = .horizontal
        startingStackView.alignment = .fill
        startingStackView.distribution = .fillEqually
        startingStackView.spacing = 0
        
        view.addSubview(startingStackView)
        startingStackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        startingStackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        startingStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        startingStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        startingStackView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        view.addSubview(titleLabel)
        titleLabel.bottomAnchor.constraint(equalTo: startingStackView.topAnchor, constant: -(view.frame.height / 4) + 150).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
}
