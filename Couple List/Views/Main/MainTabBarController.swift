//
//  MainTabBarController.swift
//  Couple List
//
//  Created by Kirin Patel on 1/2/19.
//  Copyright © 2019 Kirin Patel. All rights reserved.
//

import UIKit
import BLTNBoard
import FirebaseAuth
import FirebaseDatabase

class MainTabViewController: UITabBarController {
    
    lazy var startPage: CLBLTNPageItem = {
        let page = CLBLTNPageItem(title: "Getting Started")
        page.descriptionText = "You currently are not apart of a list. You can create one or ask your Partner to share their list with you."
        page.actionButtonTitle = "Create List"
        page.alternativeButtonTitle = "Join List"
        page.alternativeHandler = { (item: BLTNActionItem) in
            if let manager = item.manager {
                manager.push(item: self.joinListPage)
            }
        }
        return page
    }()
    
    lazy var joinListPage: CLBLTNPageItem = {
        let page = CLBLTNPageItem(title: "Join List")
        page.descriptionText = "To join your Partner's list, ask them to share it from the settings of Couple List. Then simply click the link they share to get started."
        page.actionButtonTitle = "Ok"
        page.actionHandler = { (item: BLTNActionItem) in
            if let manager = item.manager {
                manager.popItem()
            }
        }
        return page
    }()
    
    lazy var bulletinManager: BLTNItemManager = {
        return BLTNItemManager(rootItem: startPage)
    }()
    
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let listStack = UIStoryboard.init(name: "List", bundle: nil).instantiateInitialViewController()
        listStack!.tabBarItem = UITabBarItem(title: "List", image: nil, selectedImage: nil)
        
        let settingsStack = UIStoryboard.init(name: "Settings", bundle: nil).instantiateInitialViewController()
        settingsStack!.tabBarItem = UITabBarItem(title: "Settins", image: nil, selectedImage: nil)
        viewControllers = [listStack!, settingsStack!]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard handle == nil else { return }
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.determineUserStatus(uid: user.uid)
            } else {
                self.dismiss(animated: true)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let handle = handle else { return }
        Auth.auth().removeStateDidChangeListener(handle)
    }
    
    fileprivate func determineUserStatus(uid: String) {
        let ref = Database.database().reference(withPath: "users/\(uid)")
        ref.observeSingleEvent(of: .value) { snapshot in
            if snapshot.hasChild("list") && snapshot.hasChild("list/key") && snapshot.hasChild("list/code") {
                self.validateUserList(uid: uid,
                                      key: snapshot.childSnapshot(forPath: "list/key").value as? String ?? "",
                                      code: snapshot.childSnapshot(forPath: "list/code").value as? String ?? "")
            } else {
                self.bulletinManager.showBulletin(above: self)
            }
        }
    }
    
    fileprivate func validateUserList(uid: String, key: String, code: String) {
        if !key.isEmpty && !code.isEmpty {
            let ref = Database.database().reference(withPath: "lists/\(key)/activities")
            ref.observeSingleEvent(of: .value, with: { _ in
               // User is able to view list, do nothing here
            }, withCancel: { _ in
                self.removeUserFromList(uid: uid)
            })
        } else {
            removeUserFromList(uid: uid)
        }
    }
    
    fileprivate func removeUserFromList(uid: String) {
        let ref = Database.database().reference(withPath: "users/\(uid)/list")
        ref.removeValue()
        determineUserStatus(uid: uid)
    }
}
