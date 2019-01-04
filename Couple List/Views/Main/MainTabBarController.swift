//
//  MainTabBarController.swift
//  Couple List
//
//  Created by Kirin Patel on 1/2/19.
//  Copyright © 2019 Kirin Patel. All rights reserved.
//

import UIKit
import FirebaseAuth

class MainTabViewController: UITabBarController {
    
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let listStack = UIStoryboard.init(name: "List", bundle: nil).instantiateInitialViewController()
        listStack!.tabBarItem = UITabBarItem(title: "List", image: nil, selectedImage: nil)
        
        let settingsStack = UIStoryboard.init(name: "Settings", bundle: nil).instantiateInitialViewController()
        settingsStack!.tabBarItem = UITabBarItem(title: "Settings", image: nil, selectedImage: nil)
        viewControllers = [listStack!, settingsStack!]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard handle == nil else { return }
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            guard user == nil else { return }
            self.dismiss(animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let handle = handle else { return }
        Auth.auth().removeStateDidChangeListener(handle)
    }
}
