//
//  SettingsViewController.swift
//  Couple List
//
//  Created by Kirin Patel on 6/17/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import StoreKit
import FirebaseAuth
import FirebaseAnalytics
import FirebaseDatabase
import FirebaseDynamicLinks
import MessageUI

class SettingsViewController: UIViewController {
    
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
        clSettingsItem.iconImage = UIImage.init(named: "feedback")
        clSettingsItem.title = "Feedback"
        clSettingsItem.details = "Provide feedback on feature you like/dislike"
        return clSettingsItem
    }()
    
    let accountSettingsItem: CLSettingsItem = {
        let clSettingsItem = CLSettingsItem()
        clSettingsItem.iconImage = UIImage.init(named: "profilePicture")
        clSettingsItem.title = "Account Settings"
        clSettingsItem.details = "Set and change account information"
        return clSettingsItem
    }()
    
    let shareListItem: CLSettingsItem = {
        let clSettingsItem = CLSettingsItem()
        clSettingsItem.iconImage = UIImage.init(named: "share")
        clSettingsItem.title = "Share List"
        clSettingsItem.details = "Invite your partner to help"
        return clSettingsItem
    }()
    
    let adsSpacer: CLSettingsItemSpacer = {
        let clSettingsItemSpacer = CLSettingsItemSpacer()
        clSettingsItemSpacer.isHidden = CL.shared.noAds()
        return clSettingsItemSpacer
    }()
    
    let removeAdsItem: CLSettingsItem = {
        let clSettingsItem = CLSettingsItem()
        clSettingsItem.isHidden = CL.shared.noAds()
        clSettingsItem.iconImage = UIImage.init(named: "removeAds")
        clSettingsItem.title = "Remove Ads"
        clSettingsItem.details = "Get rid of pesky ads"
        return clSettingsItem
    }()
    
    let restorePurchasesItem: CLSettingsItem = {
        let clSettingsItem = CLSettingsItem()
        clSettingsItem.isHidden = CL.shared.noAds()
        clSettingsItem.iconImage = UIImage.init(named: "restore")
        clSettingsItem.title = "Restore Purchases"
        clSettingsItem.details = "Re-remove ads from your list"
        return clSettingsItem
    }()
    
    let leaveItem: CLSettingsItem = {
        let clSettingsItem = CLSettingsItem()
        clSettingsItem.iconImage = UIImage.init(named: "leave")
        clSettingsItem.title = "Leave List"
        clSettingsItem.details = "Remove your account from this list"
        return clSettingsItem
    }()
    
    let logoutItem: CLSettingsItem = {
        let clSettingsItem = CLSettingsItem()
        clSettingsItem.iconImage = UIImage.init(named: "logout")
        clSettingsItem.title = "Logout"
        clSettingsItem.details = "Sign out of the app"
        return clSettingsItem
    }()
    
    let disclaimerItem: CLSettingsItem = {
        let clSettingsItem = CLSettingsItem()
        clSettingsItem.iconImage = UIImage.init(named: "icons8")
        clSettingsItem.title = "Icons8"
        clSettingsItem.details = "Some icons used are from icons8.com"
        return clSettingsItem
    }()
    
    var products = [SKProduct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(named: "MainColor")
        title = "Settings"
        
        ref = Database.database().reference()
        
        setupView()
        NotificationCenter.default.addObserver(self, selector: #selector(handlePurchaseNotification(_:)),
                                               name: NSNotification.Name(rawValue: PurchaseHelper.PurchaseNotification),
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Products.store.requestProducts({success, products in
            self.products = []
            
            if success {
                self.products = products!
            }
        })
    }
    
    @objc func handlePurchaseNotification(_ notification: Notification) {
        guard let productID = notification.object as? String else { return }
        
        for product in products {
            guard product.productIdentifier == productID else { continue }
        }
    }
    
    @objc func handleSubmitFeedback() {
        navigationController?.pushViewController(FeedbackViewController(), animated: true)
    }
    
    @objc func handleViewAccountSettings() {
        navigationController?.pushViewController(AccountSettingsViewController(), animated: true)
    }
    
    @objc func handleShareList() {
        let alert = UIAlertController(title: "Creating Sharable Link", message: "Please wait while the link is generated.", preferredStyle: .alert)
        present(alert, animated: true)
        guard let link = URL(string: "https://couplelist.app?link=\(CL.shared.userSettings.listKey)") else {
            // TODO: Display error
            return
        }
        let components = DynamicLinkComponents(link: link, domain: "sa6cz.app.goo.gl")
        
        let analyticsParams = DynamicLinkGoogleAnalyticsParameters(source: "iOS", medium: "app", campaign: "nil")
        components.analyticsParameters = analyticsParams
        
        let iOSParams = DynamicLinkIOSParameters(bundleID: "com.kirinpatel.couplelist")
        iOSParams.fallbackURL = URL(string: link.absoluteString)
        iOSParams.minimumAppVersion = "2.0.0"
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
            alert.dismiss(animated: true)
            var link: String
            if error != nil {
                link = components.url?.absoluteString ?? ""
            } else {
                link = shortURL?.absoluteString ?? ""
            }
            let shareContent: String = "Hey, help me make our Couple List! Click this link below then use the password \"\(CL.shared.userSettings.listCode)\". \(link)"
            
            guard MFMessageComposeViewController.canSendText() else {
                let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
                self.present(activityViewController, animated: true)
                return
            }
            
            let messageController = MFMessageComposeViewController()
            messageController.messageComposeDelegate = self
            messageController.body = shareContent
            self.present(messageController, animated: true)
        }
    }
    
    @objc func handleRemoveAds() {
        if !CL.shared.noAds() && products.count > 0 {
            Products.store.buyProduct(self.products[0], view: self)
        }
    }
    
    @objc func handleRestorePurchases() {
        Products.store.setupView(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    @objc func handleLeaveList() {
        let alert = UIAlertController(title: "Are you sure you want to leave your list?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Leave", style: .destructive, handler: { _ in
            Analytics.logEvent("leave_list", parameters: [
                "device": "iOS"
                ])
            self.ref.child("lists/\(CL.shared.userSettings.listKey)/tokens").child(Auth.auth().currentUser!.uid).removeValue()
            CL.shared.userSettings = UserSettings.init(listKey: "", listCode: "")!
            self.ref.child("users/\(Auth.auth().currentUser!.uid)").removeValue()
            self.dismiss(animated: true)
        }))
        present(alert, animated: true)
    }
    
    @objc func handleLogout() {
        Analytics.logEvent("logout", parameters: [
            "device": "iOS"
            ])
        do {
            CL.shared.userSettings = UserSettings.init(listKey: "", listCode: "")!
            try Auth.auth().signOut()
            self.dismiss(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    @objc func handleViewIcons8() {
        if let url = URL(string: "https://icons8.com") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    fileprivate func setupView() {
        view.addSubview(scrollView)
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        scrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        
        submitFeedbackItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSubmitFeedback)))
        accountSettingsItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleViewAccountSettings)))
        shareListItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShareList)))
        removeAdsItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleRemoveAds)))
        restorePurchasesItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleRestorePurchases)))
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
    }
}

extension SettingsViewController: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true)
        switch (result) {
        case .sent:
            let alert = UIAlertController(title: "List Shared", message: "Your list was shared with your partner.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
            break;
        case .failed:
            let alert = UIAlertController(title: "Unable to Share List", message: "There was an error sharing your list.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
            break;
        case .cancelled:
            break;
        }
    }
}
