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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseOptions.defaultOptions()?.deepLinkURLScheme = "sa6cz.app.goo.gl"
        FirebaseApp.configure()
        GADMobileAds.configure(withApplicationID: "ca-app-pub-9026572937829340~1062002797")
        
        ref = Database.database().reference()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return application(app, open: url, sourceApplication: nil, annotation: [:])
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return false
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return true
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
}
