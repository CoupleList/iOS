//
//  SettingsViewController.swift
//  Couple List
//
//  Created by Kirin Patel on 6/17/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseAnalytics
import FirebaseDatabase
import FirebaseDynamicLinks
import MessageUI

class SettingsViewController: UIViewController, UINavigationControllerDelegate {
    
    var ref: DatabaseReference!
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.indicatorStyle = .black
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    let submitFeedbackItem: CLSettingsItem = {
        let clSettingsItem = CLSettingsItem()
        clSettingsItem.iconImage = UIImage.init(named: "SettingsFeedback")
        clSettingsItem.title = "Feedback"
        clSettingsItem.details = "Provide feedback on feature you like/dislike"
        return clSettingsItem
    }()
    
    let accountSettingsItem: CLSettingsItem = {
        let clSettingsItem = CLSettingsItem()
        clSettingsItem.iconImage = UIImage.init(named: "SettingsAccount")
        clSettingsItem.title = "Account Settings"
        clSettingsItem.details = "Set and change account information"
        return clSettingsItem
    }()
    
    let shareListItem: CLSettingsItem = {
        let clSettingsItem = CLSettingsItem()
        clSettingsItem.iconImage = UIImage.init(named: "SettingsShare")
        clSettingsItem.title = "Share List"
        clSettingsItem.details = "Invite your partner to help"
        return clSettingsItem
    }()
    
    let adsSpacer: CLSettingsItemSpacer = {
        let clSettingsItemSpacer = CLSettingsItemSpacer()
        clSettingsItemSpacer.isHidden = true
        return clSettingsItemSpacer
    }()
    
    let removeAdsItem: CLSettingsItem = {
        let clSettingsItem = CLSettingsItem()
        clSettingsItem.isHidden = true
        clSettingsItem.iconImage = UIImage.init(named: "SettingsRemoveAds")
        clSettingsItem.title = "Remove Ads"
        clSettingsItem.details = "Get rid of pesky ads"
        return clSettingsItem
    }()
    
    let restorePurchasesItem: CLSettingsItem = {
        let clSettingsItem = CLSettingsItem()
        clSettingsItem.isHidden = true
        clSettingsItem.iconImage = UIImage.init(named: "SettingsRestore")
        clSettingsItem.title = "Restore Purchases"
        clSettingsItem.details = "Re-remove ads from your list"
        return clSettingsItem
    }()
    
    let leaveItem: CLSettingsItem = {
        let clSettingsItem = CLSettingsItem()
        clSettingsItem.iconImage = UIImage.init(named: "SettingsLeave")
        clSettingsItem.title = "Leave List"
        clSettingsItem.details = "Remove your account from this list"
        return clSettingsItem
    }()
    
    let logoutItem: CLSettingsItem = {
        let clSettingsItem = CLSettingsItem()
        clSettingsItem.iconImage = UIImage.init(named: "SettingsLogout")
        clSettingsItem.title = "Logout"
        clSettingsItem.details = "Sign out of the app"
        return clSettingsItem
    }()
    
    let disclaimerItem: CLSettingsItem = {
        let clSettingsItem = CLSettingsItem()
        clSettingsItem.iconImage = UIImage.init(named: "icons8")
        clSettingsItem.title = "Icons8"
        clSettingsItem.details = "Some icons obtained from icons8.com"
        return clSettingsItem
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(named: "MainColor")
        title = "Settings"
        
        view.addSubview(scrollView)
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        scrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        
        submitFeedbackItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSubmitFeedback)))
        accountSettingsItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleViewAccountSettings)))
        shareListItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShareList)))
        leaveItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleLeaveList)))
        logoutItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleLogout)))
        disclaimerItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleViewIcons8)))
        
        let settingsSubViews: [UIView] = [
            submitFeedbackItem,
            CLSettingsItemSpacer(),
            accountSettingsItem,
            shareListItem,
            adsSpacer,
            removeAdsItem,
            restorePurchasesItem,
            CLSettingsItemSpacer(),
            leaveItem,
            logoutItem,
            CLSettingsItemSpacer(),
            disclaimerItem
        ]
        
        let settingsStackView = UIStackView(arrangedSubviews: settingsSubViews)
        settingsStackView.translatesAutoresizingMaskIntoConstraints = false
        settingsStackView.axis = .vertical
        settingsStackView.alignment = .fill
        settingsStackView.distribution = .fill
        settingsStackView.spacing = 0
        
        scrollView.addSubview(settingsStackView)
        settingsStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0).isActive = true
        settingsStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0).isActive = true
        settingsStackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        settingsStackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        
        scrollView.bounds = view.bounds
        scrollView.contentSize = CGSize(width: view.bounds.width, height: .infinity)
        
        ref = Database.database().reference()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ref.child("lists/\(AppDelegate.settings.listKey)/noAds").observeSingleEvent(of: .value, with: { (snapshot) in
            let hasAds = snapshot.exists() && snapshot.value as! Bool
            self.adsSpacer.isHidden = hasAds
            self.removeAdsItem.isHidden = hasAds
            self.restorePurchasesItem.isHidden = hasAds
        })
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func handleSubmitFeedback() {
        navigationController?.pushViewController(FeedbackViewController(), animated: true)
    }
    
    @objc func handleViewAccountSettings() {
        navigationController?.pushViewController(AccountSettingsViewController(), animated: true)
    }
    
    @objc func handleShareList() {
        guard let link = URL(string: "https://couple-list.firebaseapp.com?link=\(AppDelegate.settings.listKey)?key=\(AppDelegate.settings.listCode)") else { return }
        let components = DynamicLinkComponents(link: link, domain: "sa6cz.app.goo.gl")
        
        Analytics.logEvent("share_list", parameters: [
            "device": "iOS",
            "link": link.absoluteString
            ])
        
        let analyticsParams = DynamicLinkGoogleAnalyticsParameters(source: "iOS", medium: "app", campaign: "nil")
        components.analyticsParameters = analyticsParams
        
        let iOSParams = DynamicLinkIOSParameters(bundleID: "com.kirinpatel.couplelist")
        iOSParams.fallbackURL = URL(string: link.absoluteString)
        iOSParams.minimumAppVersion = "1.0.0"
        iOSParams.appStoreID = "1310979486"
        components.iOSParameters = iOSParams
        
        let androidParams = DynamicLinkAndroidParameters(packageName: "com.kirinpatel.couplelist")
        androidParams.fallbackURL = URL(string: link.absoluteString)
        androidParams.minimumVersion = 1
        components.androidParameters = androidParams
        
        let options = DynamicLinkComponentsOptions()
        options.pathLength = .unguessable
        components.options = options
        
        components.shorten { (shortURL, warnings, error) in
            var link: String
            if error != nil {
                link = components.url?.absoluteString ?? ""
            } else {
                link = shortURL?.absoluteString ?? ""
            }
            
            let shareContent: String = "Hey, help me make our Couple List! \(link)"
            let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: {})
        }
    }
    
    @objc func handleLeaveList() {
        Analytics.logEvent("leave_list", parameters: [
            "device": "iOS"
            ])
    }
    
    @objc func handleLogout() {
        Analytics.logEvent("logout", parameters: [
            "device": "iOS"
            ])
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    @objc func handleViewIcons8() {
        if let url = URL(string: "https://icons8.com") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
