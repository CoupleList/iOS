//
//  MainViewController.swift
//  Couple List
//
//  Created by Kirin Patel on 6/17/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging
import FirebaseStorage

class MainViewController: UITabBarController, UITabBarControllerDelegate {
    
    var handler: AuthStateDidChangeListenerHandle!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(named: "MainColor")
        tabBar.barStyle = .black
        tabBar.tintColor = .white
        
        delegate = self
        
        let uid = Auth.auth().currentUser!.uid
        ActivitiesTableViewController.profileDisplayNames.updateValue("You", forKey: uid)
        let profileImageRef = Storage.storage().reference(withPath: "profileImages/\(uid).JPG")
        profileImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let data = data {
                if let profileImage = UIImage(data: data) {
                    ActivitiesTableViewController.profileImages.updateValue(profileImage, forKey: uid)
                }
            } else {
                ActivitiesTableViewController.profileImages.updateValue(UIImage.init(named: "ProfileImagePlaceholder")!, forKey: uid)
            }
        }
        
        let navigationTab = ActivityNavigationViewController()
        navigationTab.tabBarItem = UITabBarItem(title: "Activities", image: UIImage(named: "ActivitiesImage"), selectedImage: nil)
        
        let historyTab = HistoryNavigationViewController()
        historyTab.tabBarItem = UITabBarItem(tabBarSystemItem: .history, tag: 1)
        
        let settingsTab = SettingsNavigationViewController()
        settingsTab.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: "SettingsImage"), selectedImage: nil)
        
        ref = Database.database().reference()
        
        handler = Auth.auth().addStateDidChangeListener { (auth, user) in
            if user == nil {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.ref.child("users/\(user!.uid)").observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() && !snapshot.childSnapshot(forPath: "list").exists() {
                        for child in snapshot.children.allObjects {
                            let childSnapshot = child as! DataSnapshot
                            
                            if childSnapshot.key != "list" && childSnapshot.childSnapshot(forPath: "code").exists() {
                                AppDelegate.settings.listKey = childSnapshot.key
                                AppDelegate.settings.listCode = childSnapshot.childSnapshot(forPath: "code").value as! String
                                
                                self.ref.child("/users/\(user!.uid)/list").setValue(["key": AppDelegate.settings.listKey, "code": AppDelegate.settings.listCode])
                            }
                        }
                    } else if snapshot.exists() && snapshot.childSnapshot(forPath: "list").exists() {
                        AppDelegate.settings.listKey = snapshot.childSnapshot(forPath: "list").childSnapshot(forPath: "key").value as! String
                        AppDelegate.settings.listCode = snapshot.childSnapshot(forPath: "list").childSnapshot(forPath: "code").value as! String
                    } else if !snapshot.exists() {
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                    self.ref.child("lists").child(AppDelegate.settings.listKey).child("tokens").child(user!.uid).setValue(Messaging.messaging().fcmToken)
                    
                    self.viewControllers = [ navigationTab, historyTab, settingsTab ]
                    self.selectedIndex = 0
                })
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Auth.auth().removeStateDidChangeListener(handler!)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true;
    }
}
