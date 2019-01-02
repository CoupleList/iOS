//
//  MainTabBarController.swift
//  Couple List
//
//  Created by Kirin Patel on 1/2/19.
//  Copyright © 2019 Kirin Patel. All rights reserved.
//

import UIKit

class MainTabViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settingsStack = UIStoryboard.init(name: "Settings", bundle: nil).instantiateInitialViewController()
        settingsStack!.tabBarItem = UITabBarItem(title: "Settins", image: nil, selectedImage: nil)
        viewControllers = [settingsStack!]
    }
}
