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
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleEnterForeground), name: .UIApplicationDidBecomeActive, object: nil)
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if CL.shared.userSettings.listCode.isEmpty && !CL.shared.userSettings.listKey.isEmpty {
            let alert = UIAlertController(title: "List found", message: "You previously tried to join a list, would you still like to join it?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                self.displayEnterPasswordAlert()
            }))
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { _ in
                CL.shared.userSettings.listKey = ""
                self.ref.child("users/\(Auth.auth().currentUser!.uid)").removeValue()
            }))
            present(alert, animated: true)
        }
    }
    
    @objc func handleEnterForeground() {
        if CL.shared.userSettings.listCode.isEmpty && !CL.shared.userSettings.listKey.isEmpty {
            displayEnterPasswordAlert()
        }
    }
    
    @objc func handleCreateList() {
        let alert = UIAlertController(title: "Add a password to your list", message: "This password will make sure only you and your partner can access your list. The password can be anything you like.", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "List Password"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Set", style: .default, handler: { _ in
            if let code = alert.textFields?[0].text {
                if code.isEmpty {
                    self.displayError(title: "Unable to create list", message: "A password is required!")
                } else {
                    self.createList(code: code)
                }
            } else {
                self.displayError(title: "Unable to create list", message: "Unable to parse password, please try again.")
            }
        }))
        present(alert, animated: true)
    }
    
    @objc func handleJoinList() {
        let alert = UIAlertController(title: "Join list", message: "To join your partner's Couple List, request that they share it with you from within the settings of Couple List.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true)
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
    
    fileprivate func displayError(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true)
    }
    
    fileprivate func createList(code: String) {
        let key = ref.child("user/\(Auth.auth().currentUser!.uid)").childByAutoId().key
        
        CL.shared.userSettings.listKey = key
        CL.shared.userSettings.listCode = code
        
        ref.child("users/\(Auth.auth().currentUser!.uid)/list").setValue([
            "key": CL.shared.userSettings.listKey,
            "code": CL.shared.userSettings.listCode
            ], withCompletionBlock: { (error, snapshot) in
                guard error == nil else { return }
                self.ref.child("lists/\(key)/code").setValue(code, withCompletionBlock: { (error, snapshot) in
                    guard error == nil else { return }
                    self.dismiss(animated: true)
                })
        })
    }
    
    fileprivate func displayEnterPasswordAlert() {
        let alert = UIAlertController(title: "Join list", message: "Please provide the password to join this list.", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "List Password"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Join", style: .default, handler: { _ in
            if let code = alert.textFields?[0].text {
                if code.isEmpty {
                    self.displayError(title: "Unable to join list", message: "A password is required!")
                } else {
                    self.joinList(code: code)
                }
            } else {
                self.displayError(title: "Unable to join list", message: "Unable to parse password, please try again.")
            }
        }))
        present(alert, animated: true)
    }
    
    fileprivate func joinList(code: String) {
        ref.child("users/\(Auth.auth().currentUser!.uid)/list/code").setValue(code) { (error, _) in
            guard error == nil else {
                // TODO: Display alert that an error occurred
                return
            }
            self.ref.child("lists/\(CL.shared.userSettings.listKey)/activities").observeSingleEvent(of: .value, with: { _ in
                CL.shared.userSettings.listCode = code
                self.dismiss(animated: true)
            }) { _ in
                self.ref.child("users/\(Auth.auth().currentUser!.uid)/list/code").removeValue(completionBlock: { (_, _) in
                    self.displayError(title: "Unable to join list", message: "The provided password is incorrect.")
                })
            }
        }
    }
}
