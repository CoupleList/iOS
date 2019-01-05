//
//  MainTabBarController.swift
//  Couple List
//
//  Created by Kirin Patel on 1/2/19.
//  Copyright © 2019 Kirin Patel. All rights reserved.
//

import UIKit
import Ambience
import BLTNBoard
import FirebaseAuth
import LocalAuthentication

class MainTabViewController: UITabBarController {
    
    let blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .light)
        let visualEffectView = UIVisualEffectView(effect: effect)
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.alpha = 0
        return visualEffectView
    }()
    
    var handle: AuthStateDidChangeListenerHandle?
    
    lazy var biometricAuthenticationFailedPage: CLBLTNPageItem = {
        let page = CLBLTNPageItem(title: "Unable To Validate With Biometrics")
        page.actionButtonTitle = "Retry"
        page.actionHandler = { (item: BLTNActionItem) in
            if let manager = item.manager {
                manager.dismissBulletin()
                self.validateBiometrics()
            }
        }
        return page
    }()
    
    lazy var biometricAuthenticationFailedBulletinManager: CLBLTNItemManager = {
        return CLBLTNItemManager(rootItem: biometricAuthenticationFailedPage)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let listStack = UIStoryboard.init(name: "List",
                                          bundle: nil).instantiateInitialViewController()
        listStack!.tabBarItem = UITabBarItem(title: "List",
                                             image: UIImage(named: "List"),
                                             selectedImage: nil)
        
        let settingsStack = UIStoryboard.init(name: "Settings",
                                              bundle: nil).instantiateInitialViewController()
        settingsStack!.tabBarItem = UITabBarItem(title: "Settings",
                                                 image: UIImage(named: "Settings"),
                                                 selectedImage: nil)
        viewControllers = [listStack!, settingsStack!]
        
        view.addSubview(blurView)
        blurView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        blurView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        blurView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(handleAppMovedToForeground),
                                       name: UIApplication.willEnterForegroundNotification,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(handleAppMovedToBackground),
                                       name: UIApplication.didEnterBackgroundNotification,
                                       object: nil)
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
    
    @objc func handleAppMovedToForeground() {
        let requireBiometricAuthentication = UserDefaults.standard.bool(forKey: "requireBiometricAuthentication")
        if requireBiometricAuthentication {
            validateBiometrics()
        }
    }
    
    @objc func handleAppMovedToBackground() {
        let requireBiometricAuthentication = UserDefaults.standard.bool(forKey: "requireBiometricAuthentication")
        if requireBiometricAuthentication {
            self.blurView.alpha = 1
            self.blurView.effect = UIBlurEffect(style: Ambience.currentState == .invert ? .dark : .light)
        }
    }
    
    fileprivate func validateBiometrics() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication,
                                   localizedReason: "Authenticate User Locally") { (success, error) in
                                    DispatchQueue.main.async {
                                        if success {
                                            UIView.animate(withDuration: 0.5, animations: {
                                                self.blurView.alpha = 0
                                            })
                                        } else {
                                            self.biometricAuthenticationFailedBulletinManager.show(above: self)
                                        }
                                    }
            }
        } else {
            self.biometricAuthenticationFailedBulletinManager.show(above: self)
            self.biometricAuthenticationFailedBulletinManager.push(item: CLBLTNErrorPageItem(descriptionText: "Unable to use biometric authentication. Please ensure Face ID or Touch ID is enabled for Couple List."))
        }
    }
}
