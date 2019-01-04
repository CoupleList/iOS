//
//  ListSortingTableViewController.swift
//  Couple List
//
//  Created by Kirin Patel on 1/3/19.
//  Copyright © 2019 Kirin Patel. All rights reserved.
//

import UIKit

protocol ListSortingTableViewControllerDelegate: class {
    func sortStateChanged(state: String)
    func sortTypeChanged(type: String)
}

class ListSortingTableViewController: UITableViewController {
    
    var state: String = "Incomplete" {
        didSet {
            if let delegate = delegate { delegate.sortStateChanged(state: state) }
            tableView.reloadData()
        }
    }
    
    var type: String = "All" {
        didSet {
            if let delegate = delegate { delegate.sortTypeChanged(type: type) }
            tableView.reloadData()
        }
    }
    
    var delegate: ListSortingTableViewControllerDelegate?
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let alert = UIAlertController(title: "Sort State By", message: "Filter activity states by", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Nothing", style: .default, handler: { _ in
                self.state = "All"
            }))
            alert.addAction(UIAlertAction(title: "Incomplete", style: .default, handler: { _ in
                self.state = "Incomplete"
            }))
            alert.addAction(UIAlertAction(title: "Complete", style: .default, handler: { _ in
                self.state = "Complete"
            }))
            self.present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: "Sort Type By", message: "Filter activity types by", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Nothing", style: .default, handler: { _ in
                self.type = "All"
            }))
            alert.addAction(UIAlertAction(title: "Text Only", style: .default, handler: { _ in
                self.type = "Text"
            }))
            alert.addAction(UIAlertAction(title: "Has Location", style: .default, handler: { _ in
                self.type = "Location"
            }))
            self.present(alert, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "default")
        cell.textLabel?.text = indexPath.row == 0 ? "State" : "Type"
        cell.detailTextLabel?.text = indexPath.row == 0 ? state : type
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}
