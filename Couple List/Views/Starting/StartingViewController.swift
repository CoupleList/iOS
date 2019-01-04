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
        page.alternativeHandler = { (item: BLTNActionItem) in
            if let manager = item.manager {
                manager.push(item: self.registerPage)
            }
        }
        return page
    }()
    
    lazy var loginPage: CLBTNLoginPageItem = self.generateLoginPageItem()
    
    lazy var registerPage: CLBLTNRegisterPageItem = self.generateRegisterPageItem()
    
    lazy var welcomePage: CLBLTNPageItem = {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                if !self.definesPresentationContext {
                    do {
                        try CLDefaults.shared.checkForListForUser(completion: { list in
                            if list != nil {
                                self.goToMain()
                            } else {
                                self.bulletinManager.showBulletin(above: self)
                                self.bulletinManager.push(item: self.welcomePage)
                            }
                        })
                    } catch {
                        self.displayAlertOverBulletinManager(title: "An Unexpected Error Occurred",
                                                             message: "You account was unable to be verified. Please ensure your device has an internet connection.")
                    }
                }
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
    
    fileprivate func goToMain() {
        let mainViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateInitialViewController()
        present(mainViewController!, animated: true)
    }
    
    fileprivate func generateLoginPageItem(_ emailAddress: String = "") -> CLBTNLoginPageItem {
        let page = CLBTNLoginPageItem(emailAddress: emailAddress)
        page.actionHandler = { (item: BLTNActionItem) in
            let emailAddress = page.emailAddressTextField.text
            let password = page.passwordTextField.text
            self.login(emailAddress: emailAddress ?? "", password: password ?? "")
        }
        return page
    }
    
    fileprivate func generateRegisterPageItem(_ emailAddress: String = "") -> CLBLTNRegisterPageItem {
        let page = CLBLTNRegisterPageItem(emailAddress: emailAddress)
        page.actionHandler = { (item: BLTNActionItem) in
            let emailAddress = page.emailAddressTextField.text
            let password = page.passwordTextField.text
            let confirmPassword = page.confirmPasswordTextField.text
            
            if password != confirmPassword {
                self.displayAlertOverBulletinManager(title: "Mismatching Passwords",
                                                     message: "You must provide identical passwords when creating your account.")
            } else {
                self.register(emailAddress: emailAddress ?? "",
                              password: password ?? "")
            }
        }
        return page
    }
    
    fileprivate func displayAlertOverBulletinManager(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        bulletinManager.present(alert, animated: true)
    }
    
    fileprivate func login(emailAddress: String, password: String) {
        if !emailAddress.isEmpty && !password.isEmpty {
            bulletinManager.displayActivityIndicator()
            Auth.auth().signIn(withEmail: emailAddress, password: password) { (result, error) in
                if let error = error {
                    self.bulletinManager.hideActivityIndicator()
                    let errorPageItem = CLBLTNErrorPageItem(descriptionText: error.localizedDescription)
                    errorPageItem.actionHandler = { (item: BLTNActionItem) in
                        if let manager = item.manager {
                            manager.push(item: self.generateLoginPageItem(emailAddress))
                        }
                    }
                    self.bulletinManager.push(item: errorPageItem)
                } else {
                    do {
                        try CLDefaults.shared.checkForListForUser(completion: { list in
                            if list != nil {
                                self.bulletinManager.dismissBulletin()
                                self.goToMain()
                            } else {
                                self.bulletinManager.push(item: self.welcomePage)
                            }
                        })
                    } catch {
                        self.displayAlertOverBulletinManager(title: "An Unexpected Error Occurred",
                                                             message: "You account was unable to be verified. Please ensure your device has an internet connection.")
                    }
                }
            }
        } else {
            self.displayAlertOverBulletinManager(title: "Missing Information",
                                                 message: "An email address and password are required.")
        }
    }
    
    fileprivate func register(emailAddress: String, password: String) {
        if !emailAddress.isEmpty && !password.isEmpty {
            bulletinManager.displayActivityIndicator()
            Auth.auth().createUser(withEmail: emailAddress, password: password) { (result, error) in
                self.bulletinManager.hideActivityIndicator()
                if let error = error {
                    let errorPageItem = CLBLTNErrorPageItem(descriptionText: error.localizedDescription)
                    errorPageItem.actionHandler = { (item: BLTNActionItem) in
                        if let manager = item.manager {
                            manager.push(item: self.generateRegisterPageItem(emailAddress))
                        }
                    }
                } else {
                    self.bulletinManager.push(item: self.welcomePage)
                }
            }
        } else {
            self.displayAlertOverBulletinManager(title: "Missing Information",
                                                 message: "An email address and passwords are required.")
        }
    }
}
