//
//  SettingsTableViewController.swift
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
import SafariServices

enum CLSettingsRowType {
    case simple
    case details
    case simplifiedDetails
    case toggle
}

struct CLSettingsRow {
    var title: String
    var description: String? = nil
    var type: CLSettingsRowType = .simple
    var action: (() -> Void)? = nil
    
    init(title: String) {
        self.title = title
    }
    
    init(title: String, description: String?, type: CLSettingsRowType = .simple, action: (() -> Void)? = nil) {
        self.title = title
        self.description = description
        self.type = type
        self.action = action
    }
}

class SettingsTableViewController: UITableViewController {
    
    let sections = ["App Settings",
                    "Account Settings",
                    "List Settings",
                    "Notification Settings",
                    "In App Purchases",
                    "Disclaimers"]
    lazy var rows = [[CLSettingsRow(title: "App Theme",
                                    description: Ambience.currentState == .invert ? "Dark" : "Light",
                                    type: .simplifiedDetails,
                                    action: setAppTheme)],
                     [CLSettingsRow(title: "Logout",
                                    description: Auth.auth().currentUser?.email,
                                    action: logout)],
                    [CLSettingsRow(title: "Share List",
                                   description: "Invite your partner to your list",
                                   type: .details),
                     CLSettingsRow(title: "Biometric Authentication",
                                   description: UserDefaults.standard.bool(forKey: "requireBiometricAuthentication") ? "Yes" : "No",
                                   type: .simplifiedDetails,
                                   action: toggleBiometricAuthentication),
                     CLSettingsRow(title: "Leave List",
                                   description: nil,
                                   action: leaveList)],
                    [CLSettingsRow(title: "Receive Notifications",
                                   description: "No",
                                   type: .simplifiedDetails)],
                    [],
                    [CLSettingsRow(title: "Icons",
                                   description: "All icons were obtained from icons8.com",
                                   type: .details,
                                   action: viewIcons8Website),
                     CLSettingsRow(title: "Privacy",
                                   description: nil,
                                   type: .simplifiedDetails,
                                   action: viewPrivacy)]]
    
    lazy var enableBiometricAuthenticationPage: CLBLTNPageItem = {
        let context = LAContext()
        var error: NSError?
        context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
        if let error = error {
            return CLBLTNErrorPageItem(descriptionText: "Unable to enable biometric authentication on this device.")
        }
        let page = CLBLTNPageItem(title: "Enable Biometric Authentication")
        page.image = context.biometryType == .faceID ? UIImage(named: "FaceID") : UIImage(named: "TouchID")
        page.descriptionText = "Secure your list and account data by requiring that biometric authentication is verified before accessing Couple List on this device."
        page.actionButtonTitle = "Enable"
        page.alternativeButtonTitle = "Cancel"
        page.actionHandler = { (item: BLTNActionItem) in
            if let manager = item.manager {
                UserDefaults.standard.set(true, forKey: "requireBiometricAuthentication")
                self.tableView.reloadData()
                manager.push(item: self.biometricAuthenticationEnabledPage)
            }
        }
        page.alternativeHandler = { (item: BLTNActionItem) in
            if let manager = item.manager {
                manager.dismissBulletin()
            }
        }
        return page
    }()
    
    lazy var biometricAuthenticationEnabledPage: CLBLTNPageItem = {
        let page = CLBLTNPageItem(title: "Biometric Authentication Enabled")
        page.actionButtonTitle = "Complete"
        page.actionHandler = { (item: BLTNActionItem) in
            if let manager = item.manager {
                manager.dismissBulletin()
            }
        }
        return page
    }()
    
    lazy var enableBioetricAuthenticationBulletinManager: CLBLTNItemManager = {
        return CLBLTNItemManager(rootItem: enableBiometricAuthenticationPage)
    }()
    
    lazy var disableBiometricAuthenticationPage: CLBLTNPageItem = {
        let page = CLBLTNPageItem(title: "Disable Biometric Authentication")
        page.descriptionText = "Remove biometric authentication and its requirement to be verified before viewing any list or account data within Couple List on this device."
        page.actionButtonTitle = "Disable"
        page.alternativeButtonTitle = "Cancel"
        page.actionHandler = { (item: BLTNActionItem) in
            if let manager = item.manager {
                UserDefaults.standard.set(false, forKey: "requireBiometricAuthentication")
                self.tableView.reloadData()
                manager.push(item: self.biometricAuthenticationDisabledPage)
            }
        }
        page.alternativeHandler = { (item: BLTNActionItem) in
            if let manager = item.manager {
                manager.dismissBulletin()
            }
        }
        return page
    }()
    
    lazy var biometricAuthenticationDisabledPage: CLBLTNPageItem = {
        let page = CLBLTNPageItem(title: "Biometric Authentication Disabled")
        page.actionButtonTitle = "Complete"
        page.actionHandler = { (item: BLTNActionItem) in
            if let manager = item.manager {
                manager.dismissBulletin()
            }
        }
        return page
    }()
    
    lazy var disableBiometricAuthenticationBulletinManager: CLBLTNItemManager = {
        return CLBLTNItemManager(rootItem: disableBiometricAuthenticationPage)
    }()
    
    lazy var themePage: CLBLTNPageItem = {
        let page = CLBLTNPageItem(title: "Set App Theme")
        page.actionButtonTitle = "Dark"
        page.actionHandler = { (item: BLTNActionItem) in
            if let manager = item.manager {
                Ambience.forcedState = .invert
                manager.dismissBulletin()
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { _ in
                    self.tableView.reloadData()
                })
            }
        }
        page.alternativeButtonTitle = "Light"
        page.alternativeHandler = { (item: BLTNActionItem) in
            if let manager = item.manager {
                Ambience.forcedState = .regular
                manager.dismissBulletin()
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { _ in
                    self.tableView.reloadData()
                })
            }
        }
        return page
    }()
    
    lazy var setAppThemeBulletinManager: CLBLTNItemManager = {
        return CLBLTNItemManager(rootItem: themePage)
    }()
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = rows[indexPath.section][indexPath.row]
        
        switch cellData.type {
        case .simple:
            if let description = cellData.description {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "subtitle") else {
                    fatalError("The dequeued cell is not an instance of UITableViewCell")
                }
                cell.textLabel!.text = cellData.title
                cell.detailTextLabel!.text = description
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "basic") else {
                    fatalError("The dequeued cell is not an instance of UITableViewCell")
                }
                cell.textLabel!.text = cellData.title
                return cell
            }
        case .details:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "subtitle") else {
                fatalError("The dequeued cell is not an instance of UITableViewCell")
            }
            cell.textLabel!.text = cellData.title
            if let description = cellData.description {
                cell.detailTextLabel!.text = description
            }
            cell.accessoryType = .disclosureIndicator
            return cell
        case .simplifiedDetails:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "simplifiedDetails") else {
                fatalError("The dequeued cell is not an instance of UITableViewCell")
            }
            cell.textLabel!.text = cellData.title
            if let description = cellData.description {
                if cellData.title == "Biometric Authentication" {
                    cell.detailTextLabel!.text = UserDefaults.standard.bool(forKey: "requireBiometricAuthentication") ? "Yes" : "No"
                } else if cellData.title == "App Theme" {
                    cell.detailTextLabel!.text = Ambience.currentState == .invert ? "Dark" : "Light"
                } else {
                    cell.detailTextLabel!.text = description
                }
            }
            cell.accessoryType = .disclosureIndicator
            return cell
        case .toggle:
            let cell = UITableViewCell(style: cellData.type == .simplifiedDetails ? .value1 : .subtitle, reuseIdentifier: "cell")
            cell.textLabel!.text = cellData.title
            if let description = cellData.description {
                cell.detailTextLabel!.text = description
            }
            cell.accessoryView = UISwitch()
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellData = rows[indexPath.section][indexPath.row]
        if let action: () -> Void = cellData.action {
            action()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    fileprivate func leaveList() {
        let alert = UIAlertController(title: "Are you Sure you Want to Leave Your List?",
                                      message: "If you leave your list you will be unable to rejoin it without an invite.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Leave", style: .destructive, handler: { _ in
            do {
                try CLDefaults.shared.leaveList()
            } catch is Error {
                // Ignore error
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    fileprivate func logout() {
        let alert = UIAlertController(title: "Are you Sure you Want to Logout?",
                                      message: "Logging out of Couple List will require you to re-enter your credentials.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { _ in
            do {
                try Auth.auth().signOut()
            } catch is NSError {
                // Ignore error
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    fileprivate func viewIcons8Website() {
        if let url = URL(string: "https://icons8.com/") {
            let view = SFSafariViewController(url: url)
            present(view, animated: true)
        }
    }
    
    fileprivate func viewPrivacy() {
        if let url = URL(string: "https://couplelist.app/privacy") {
            let view = SFSafariViewController(url: url)
            present(view, animated: true)
        }
    }
    
    fileprivate func toggleBiometricAuthentication() {
        tableView.reloadData()
        let requireBiometricAuthentication = UserDefaults.standard.bool(forKey: "requireBiometricAuthentication")
        if requireBiometricAuthentication {
            disableBiometricAuthenticationBulletinManager.show(above: self)
        } else {
            enableBioetricAuthenticationBulletinManager.show(above: self)
        }
    }
    
    fileprivate func setAppTheme() {
        tableView.reloadData()
        setAppThemeBulletinManager.show(above: self)
    }
}
