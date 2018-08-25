//
//  AppDelegate.swift
//  Couple List
//
//  Created by Kirin Patel on 6/3/17.
//  Copyright © 2017 Kirin Patel. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseAnalytics
import FirebaseDatabase
import FirebaseDynamicLinks
import FirebaseMessaging
import AudioToolbox
import UserNotifications
import os.log

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var ref: DatabaseReference!
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseOptions.defaultOptions()?.deepLinkURLScheme = "sa6cz.app.goo.gl"
        FirebaseApp.configure()
        GADMobileAds.configure(withApplicationID: "ca-app-pub-9026572937829340~1062002797")
        
        ref = Database.database().reference()
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert], completionHandler: {(granted, error) in
            if (granted) {
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.registerForRemoteNotifications()
                })
            }
        })
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.tintColor = UIColor.init(named: "MainColor")
        self.window?.rootViewController = StartViewController()
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return application(app, open: url, sourceApplication: nil, annotation: [:])
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url)
        if (dynamicLink?.url?.absoluteString != nil) {
            loadDynamicLink(link: (dynamicLink?.url?.absoluteString)!)
        }
        return false
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        if (application.applicationIconBadgeNumber > 0) {
            application.applicationIconBadgeNumber = 0
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if (application.applicationIconBadgeNumber > 0) {
            application.applicationIconBadgeNumber = 0
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        application.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    private func loadDynamicLink(link : String) {
        if (!link.isEmpty) {
            CL.shared.userSettings = UserSettings.generateFromLink(link: link)
            let userID = Auth.auth().currentUser?.uid
            if userID != nil {
                ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                    if (!snapshot.exists()) {
                        self.ref.child("users/\(userID!)/list").setValue(["key": CL.shared.userSettings.listKey, "code": CL.shared.userSettings.listCode])
                    }
                }) { (error) in
                    Analytics.logEvent("register_pressed", parameters: [
                        "device": "iOS",
                        "error": error.localizedDescription,
                        "link": link
                        ])
                }
            }
        }
    }
}
