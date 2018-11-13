//
//  AccountDataViewController.swift
//  Couple List
//
//  Created by Kirin Patel on 7/6/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseAnalytics
import FirebaseDatabase
import FirebaseStorage

class AccountDataViewController: UIViewController {
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = false
        scrollView.indicatorStyle = .white
        return scrollView
    }()
    
    let userProgressItem: CLSettingsProgressItem = {
        let clSettingsProgressItem = CLSettingsProgressItem()
        clSettingsProgressItem.iconImage = UIImage.init(named: "profilePicture")
        clSettingsProgressItem.title = "Account Information"
        clSettingsProgressItem.details = "View all account information"
        return clSettingsProgressItem
    }()
    
    let testingItem: CLSettingsItem = {
        let clSettingsItem = CLSettingsItem()
        clSettingsItem.title = CL.shared.userSettings.listKey
        clSettingsItem.details = Auth.auth().currentUser!.uid
        return clSettingsItem
    }()
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(named: "MainColor")
        title = "Account Data"
        
        ref = Database.database().reference()
        
        setupView()
        loadAccountData()
    }
    
    fileprivate func setupView() {
        view.addSubview(scrollView)
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        scrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        
        let accountSettingsSubViews: [UIView] = [
            testingItem
        ]
        
        let accountSettingsStackView = UIStackView(arrangedSubviews: accountSettingsSubViews)
        accountSettingsStackView.translatesAutoresizingMaskIntoConstraints = false
        accountSettingsStackView.axis = .vertical
        accountSettingsStackView.alignment = .fill
        accountSettingsStackView.distribution = .fill
        accountSettingsStackView.spacing = 0
        
        scrollView.addSubview(accountSettingsStackView)
        accountSettingsStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0).isActive = true
        accountSettingsStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0).isActive = true
        accountSettingsStackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        accountSettingsStackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        
        scrollView.bounds = view.bounds
        scrollView.contentSize = CGSize(width: view.bounds.width, height: .infinity)
    }
    
    fileprivate func loadAccountData() {
//        let uid = Auth.auth().currentUser!.uid
//        ref.child("users/\(uid)").observeSingleEvent(of: .value) { snapshot in
//            for (index, child) in snapshot.children.enumerated() {
//                let _ = child as! DataSnapshot
//                self.userProgressItem.progress = Float(index / Int(snapshot.childrenCount))
//            }
//        }
//        ref.child("lists/\(CL.shared.userSettings.listKey)").observeSingleEvent(of: .value) { snapshot in
//            for (index, child) in snapshot.children.enumerated() {
//                let _ = child as! DataSnapshot
//            }
//        }
    }
}
