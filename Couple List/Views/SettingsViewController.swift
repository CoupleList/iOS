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

class SettingsViewController: UIViewController, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate {
    
    var ref: DatabaseReference!
    
    let submitFeedbackButton: CLPrimaryButton = {
        let button = CLPrimaryButton(title: "feedback")
        button.setTitleColor(UIColor.init(named: "AppleBlue"), for: .normal)
        button.addTarget(self, action: #selector(handleSubmitFeedback), for: .touchUpInside)
        return button
    }()
    
    let accountSettingsButton: CLPrimaryButton = {
        let button = CLPrimaryButton(title: "account")
        button.setTitleColor(UIColor.init(named: "AppleBlue"), for: .normal)
        button.addTarget(self, action: #selector(handleViewAccountSettings), for: .touchUpInside)
        return button
    }()
    
    let shareListButton: CLPrimaryButton = {
        let button = CLPrimaryButton(title: "share list")
        button.setTitleColor(UIColor.init(named: "AppleBlue"), for: .normal)
        button.addTarget(self, action: #selector(handleShareList), for: .touchUpInside)
        return button
    }()
    
    let removeAdsButton: CLPrimaryButton = {
        let button = CLPrimaryButton(title: "remove ads ($0.99)")
        button.isHidden = true
        button.addTarget(self, action: #selector(handleShareList), for: .touchUpInside)
        return button
    }()
    
    let restorePurchasesButton: CLPrimaryButton = {
        let button = CLPrimaryButton(title: "restore purchases")
        button.isHidden = true
        button.addTarget(self, action: #selector(handleShareList), for: .touchUpInside)
        return button
    }()
    
    let leaveListButton: CLPrimaryButton = {
        let button = CLPrimaryButton(title: "leave list")
        button.setTitleColor(UIColor.init(named: "AppleRed"), for: .normal)
        button.addTarget(self, action: #selector(handleLeaveList), for: .touchUpInside)
        return button
    }()
    
    let logoutButton: CLPrimaryButton = {
        let button = CLPrimaryButton(title: "logout")
        button.setTitleColor(UIColor.init(named: "AppleRed"), for: .normal)
        button.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        return button
    }()
    
    let disclaimerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Icons obtained from icons8.com."
        label.numberOfLines = 0
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(named: "MainColor")
        title = "Settings"
        
        let topStackView = UIStackView(arrangedSubviews: [submitFeedbackButton, accountSettingsButton])
        topStackView.translatesAutoresizingMaskIntoConstraints = false
        topStackView.axis = .horizontal
        topStackView.alignment = .fill
        topStackView.distribution = .fillEqually
        topStackView.spacing = 10.0
        
        view.addSubview(topStackView)
        topStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10.0).isActive = true
        topStackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 40.0).isActive = true
        topStackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -40.0).isActive = true
        topStackView.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        view.addSubview(shareListButton)
        shareListButton.topAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: 10.0).isActive = true
        shareListButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 40.0).isActive = true
        shareListButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -40.0).isActive = true
        shareListButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        view.addSubview(removeAdsButton)
        removeAdsButton.topAnchor.constraint(equalTo: shareListButton.bottomAnchor, constant: 10.0).isActive = true
        removeAdsButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 40.0).isActive = true
        removeAdsButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -40.0).isActive = true
        removeAdsButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        view.addSubview(restorePurchasesButton)
        restorePurchasesButton.topAnchor.constraint(equalTo: removeAdsButton.bottomAnchor, constant: 10.0).isActive = true
        restorePurchasesButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 40.0).isActive = true
        restorePurchasesButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -40.0).isActive = true
        restorePurchasesButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        view.addSubview(disclaimerLabel)
        disclaimerLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8.0).isActive = true
        disclaimerLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 40.0).isActive = true
        disclaimerLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -40.0).isActive = true
        
        let bottomStackView = UIStackView(arrangedSubviews: [leaveListButton, logoutButton])
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.axis = .horizontal
        bottomStackView.alignment = .fill
        bottomStackView.distribution = .fillEqually
        bottomStackView.spacing = 10.0
        
        view.addSubview(bottomStackView)
        bottomStackView.bottomAnchor.constraint(equalTo: disclaimerLabel.topAnchor, constant: -8.0).isActive = true
        bottomStackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 40.0).isActive = true
        bottomStackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -40.0).isActive = true
        bottomStackView.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        ref = Database.database().reference()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ref.child("lists/\(AppDelegate.settings.listKey)/noAds").observeSingleEvent(of: .value, with: { (snapshot) in
            let hasAds = snapshot.exists() && snapshot.value as! Bool
            self.removeAdsButton.isHidden = hasAds
            self.restorePurchasesButton.isHidden = hasAds
        })
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result) {
        case .sent:
            let alert = UIAlertController(title: "List Shared!", message: "Your list was shared with your S.O.", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okAction)
            
            self.present(alert, animated: true, completion: nil)
            break;
        case .failed:
            break;
        case .cancelled:
            break;
        }
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
            "link": link
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
            
            guard MFMessageComposeViewController.canSendText() else {
                let shareContent: String = "Hey, help me make our Couple List! \(link)"
                let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
                self.present(activityViewController, animated: true, completion: {})
                return
            }
            
            let messageController = MFMessageComposeViewController()
            messageController.delegate = self
            messageController.body = "Hey, help me make our Couple List! \(link)"
            self.present(messageController, animated: true, completion: {})
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
}
