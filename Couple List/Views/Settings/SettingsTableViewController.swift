//
//  SettingsTableViewController.swift
//  Couple List
//
//  Created by Kirin Patel on 1/2/19.
//  Copyright © 2019 Kirin Patel. All rights reserved.
//

import UIKit
import FirebaseAuth

enum CLSettingsRowType {
    case simple
    case details
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
                    "In App Purchases"]
    let rows = [[CLSettingsRow(title: "Set Display Name",
                               description: nil,
                               type: .details,
                               action: nil),
                 CLSettingsRow(title: "Set Profile Picture",
                               description: nil,
                               type: .details,
                               action: nil),
                 CLSettingsRow(title: "Logout",
                               description: nil,
                               type: .simple,
                               action: logout)],
                [],
                [],
                [],
                [],
                []]
    
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
                let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "subtitle")
                cell.textLabel!.text = cellData.title
                cell.detailTextLabel!.text = description
                return cell
            } else {
                let cell = UITableViewCell(style: .default, reuseIdentifier: "default")
                cell.textLabel!.text = cellData.title
                return cell
            }
        case .details:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "default")
            cell.textLabel!.text = cellData.title
            return cell
        case .toggle:
            return UITableViewCell(style: .default, reuseIdentifier: "default")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellData = rows[indexPath.section][indexPath.row]
        if let action: () -> Void = cellData.action {
            action()
        }
    }
    
    fileprivate static func logout() {
        do {
          try Auth.auth().signOut()
        } catch let signOutError as NSError {
            // TODO: Handle error
        }
    }
}
