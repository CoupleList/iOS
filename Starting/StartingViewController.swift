//
//  StartingViewController.swift
//  Couple List
//
//  Created by Kirin Patel on 1/2/19.
//  Copyright © 2019 Kirin Patel. All rights reserved.
//

import UIKit
import BLTNBoard
import FirebaseAnalytics
import FirebaseAuth
import FirebaseDatabase

class StartingViewController: UIViewController {
    
    lazy var startPage: CLBLTNPageItem = {
        let page = CLBLTNPageItem(title: "Couple List")
        page.descriptionText = "The bucket list app for couples. To get started, login or create an account."
        page.actionButtonTitle = "Login"
        page.alternativeButtonTitle = "Register"
        page.actionHandler = { (item: BLTNActionItem) in
            if let manager = item.manager {
                manager.push(item: self.loginPage)
            }
        }
        return page
    }()
    
    lazy var loginPage: CLBTNLoginPageItem = {
        let page = CLBTNLoginPageItem()
        page.actionHandler = { (item: BLTNActionItem) in
            print(page.emailAddressTextField.text ?? "No email")
            print(page.passwordTextField.text ?? "No password")
        }
        return page
    }()
    
    lazy var bulletinManager: BLTNItemManager = {
        return BLTNItemManager(rootItem: startPage)
    }()
    
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard handle == nil else { return }
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                
            } else {
                self.bulletinManager.showBulletin(above: self)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let handle = handle else { return }
        Auth.auth().removeStateDidChangeListener(handle)
    }
}
