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
        
        ref = Database.database().reference()
        
        verifyCanAccesList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let handler = handler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true;
    }
    
    fileprivate func verifyCanAccesList() {
        ref.child("users/\(Auth.auth().currentUser!.uid)/list").observeSingleEvent(of: .value, with: { snapshot in
            if let key = snapshot.childSnapshot(forPath: "key").value as? String {
                self.ref.child("lists/\(key)").observeSingleEvent(of: .value, with: { _ in
                    self.loadList()
                }, withCancel: { _ in
                    self.ref.child("users/\(Auth.auth().currentUser!.uid)/list/code").removeValue(completionBlock: { (_, _) in
                        let alert = UIAlertController(title: "Cannot view list", message: "You do not have permission to view this list.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                            self.dismiss(animated: true)
                        }))
                        self.present(alert, animated: true)
                    })
                })
            }
        })
    }
    
    fileprivate func loadList() {
        let uid = Auth.auth().currentUser!.uid
        CL.shared.profileDisplayNames.updateValue("You", forKey: uid)
        let profileImageRef = Storage.storage().reference(withPath: "profileImages/\(uid).JPG")
        profileImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let data = data {
                if let profileImage = UIImage(data: data) {
                    CL.shared.profileImages.updateValue(profileImage, forKey: uid)
                }
            } else {
                CL.shared.profileImages.updateValue(UIImage.init(named: "ProfileImagePlaceholder")!, forKey: uid)
            }
        }
        
        let navigationTab = ActivityNavigationViewController()
        navigationTab.tabBarItem = UITabBarItem(title: "Activities", image: UIImage(named: "ActivitiesImage"), selectedImage: nil)
        
        let historyTab = HistoryNavigationViewController()
        historyTab.tabBarItem = UITabBarItem(tabBarSystemItem: .history, tag: 1)
        
        let settingsTab = SettingsNavigationViewController()
        settingsTab.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: "SettingsImage"), selectedImage: nil)
        
        handler = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.ref.child("users/\(user.uid)").observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.childSnapshot(forPath: "displayName").exists() {
                        if let displayName = snapshot.childSnapshot(forPath: "displayName").value as? String {
                            CL.shared.setDisplayName(displayName: displayName)
                        }
                    }
                    
                    if snapshot.exists() && !snapshot.childSnapshot(forPath: "list").exists() {
                        for child in snapshot.children.allObjects {
                            let childSnapshot = child as! DataSnapshot
                            
                            if childSnapshot.key != "list" && childSnapshot.childSnapshot(forPath: "code").exists() {
                                CL.shared.userSettings.listKey = childSnapshot.key
                                CL.shared.userSettings.listCode = childSnapshot.childSnapshot(forPath: "code").value as! String
                                
                                self.ref.child("users/\(user.uid)/list").setValue(["key": CL.shared.userSettings.listKey, "code": CL.shared.userSettings.listCode])
                            }
                        }
                    } else if snapshot.exists() && snapshot.childSnapshot(forPath: "list").exists() {
                        CL.shared.userSettings.listKey = snapshot.childSnapshot(forPath: "list/key").value as! String
                        CL.shared.userSettings.listCode = snapshot.childSnapshot(forPath: "list/code").value as! String
                        
                        self.ref.child("lists/\(CL.shared.userSettings.listKey)/noAds").observeSingleEvent(of: .value, with: { snapshot in
                            if snapshot.exists() {
                                if let noAds = snapshot.value as? Bool {
                                    CL.shared.setNoAds(noAds: noAds)
                                } else {
                                    CL.shared.setNoAds(noAds: false)
                                }
                            } else {
                                CL.shared.setNoAds(noAds: false)
                            }
                        })
                    }
                    
                    if !snapshot.exists() || CL.shared.userSettings.listKey.isEmpty {
                        self.dismiss(animated: true)
                    } else {
                        self.ref.child("lists/\(CL.shared.userSettings.listKey)/tokens/\(user.uid)").setValue(Messaging.messaging().fcmToken)
                        
                        self.viewControllers = [ navigationTab, historyTab, settingsTab ]
                        self.selectedIndex = 0
                    }
                })
            } else {
                self.dismiss(animated: true)
            }
        }
    }
}
