//
//  SettingsTableViewController.swift
//  Couple List
//
//  Created by Kirin Patel on 1/2/19.
//  Copyright © 2019 Kirin Patel. All rights reserved.
//

import UIKit
import FirebaseAuth
import SafariServices

enum CLSettingsRowType {
    case simple
    case details
    case simplifiedDetails
    case toggle
}

struct CLSettingsRow {
    var title: String
    var description: String?
    var type: CLSettingsRowType = .simple
    var action: (() -> Void)?
}

class SettingsTableViewController: UITableViewController {
    
    let sections = ["Account Settings",
                    "List Settings",
                    "Notification Settings",
                    "Location Settings",
                    "Feedback",
                    "In App Purchases",
                    "Disclaimers"]
    lazy var rows = [[CLSettingsRow(title: "Set Display Name",
                               description: nil,
                               type: .simplifiedDetails,
                               action: nil),
                 CLSettingsRow(title: "Set Profile Picture",
                               description: nil,
                               type: .simple,
                               action: nil),
                 CLSettingsRow(title: "Logout",
                               description: Auth.auth().currentUser?.email,
                               type: .simple,
                               action: logout)],
                [CLSettingsRow(title: "Share List",
                               description: "Invite your partner to your list",
                               type: .details,
                               action: nil),
                 CLSettingsRow(title: "View List History",
                               description: "View all saved history of your list",
                               type: .details,
                               action: nil),
                 CLSettingsRow(title: "Leave List",
                               description: nil,
                               type: .simple,
                               action: nil)],
                [CLSettingsRow(title: "Receive Notifications",
                               description: "No",
                               type: .simplifiedDetails,
                               action: nil)],
                [],
                [],
                [],
                [CLSettingsRow(title: "Icons",
                               description: "All icons were obtained from icons8.com",
                               type: .details,
                               action: viewIcons8Website),
                 CLSettingsRow(title: "Privacy",
                               description: nil,
                               type: .details,
                               action: viewPrivacy)]]
    
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
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "subtitle")
            cell.textLabel!.text = cellData.title
            if let description = cellData.description {
                cell.detailTextLabel!.text = description
            }
            return cell
        case .details:
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "default")
            cell.textLabel!.text = cellData.title
            if let description = cellData.description {
                cell.detailTextLabel!.text = description
            }
            cell.accessoryType = .disclosureIndicator
            return cell
        case .simplifiedDetails:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "default")
            cell.textLabel!.text = cellData.title
            if let description = cellData.description {
                cell.detailTextLabel!.text = description
            }
            cell.accessoryType = .disclosureIndicator
            return cell
        case .toggle:
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "default")
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
    }
    
    fileprivate func logout() {
        do {
          try Auth.auth().signOut()
        } catch let signOutError as NSError {
            // TODO: Handle error
        }
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
}
