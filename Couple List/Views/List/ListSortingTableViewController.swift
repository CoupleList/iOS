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
    func sortOrderChanged(order: String)
}

class ListSortingTableViewController: UITableViewController {
    
    let sections = ["Filter By", "Sort By"]
    
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
    
    var order: String = "Recent" {
        didSet {
            if let delegate = delegate { delegate.sortOrderChanged(order: order) }
            tableView.reloadData()
        }
    }
    
    var delegate: ListSortingTableViewControllerDelegate?
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [2, 1][section]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let alert = UIAlertController(title: "Sort State By",
                                              message: "Filter activity states by",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Nothing",
                                              style: .default,
                                              handler: { _ in
                                                self.state = "All"
                }))
                alert.addAction(UIAlertAction(title: "Incomplete",
                                              style: .default,
                                              handler: { _ in
                                                self.state = "Incomplete"
                }))
                alert.addAction(UIAlertAction(title: "Complete",
                                              style: .default,
                                              handler: { _ in
                                                self.state = "Complete"
                }))
                self.present(alert, animated: true)
            } else {
                let alert = UIAlertController(title: "Sort Type By",
                                              message: "Filter activity types by",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Nothing",
                                              style: .default,
                                              handler: { _ in
                                                self.type = "All"
                }))
                alert.addAction(UIAlertAction(title: "Text Only",
                                              style: .default,
                                              handler: { _ in
                                                self.type = "Text"
                }))
                alert.addAction(UIAlertAction(title: "Has Location",
                                              style: .default,
                                              handler: { _ in
                                                self.type = "Location"
                }))
                self.present(alert, animated: true)
            }
        } else {
            let alert = UIAlertController(title: "Order By",
                                          message: "",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Recent First",
                                          style: .default,
                                          handler: { _ in
                                            self.order = "Recent"
                                          }))
            alert.addAction(UIAlertAction(title: "Oldest First",
                                          style: .default,
                                          handler: { _ in
                                            self.order = "Oldest"
                                          }))
            self.present(alert, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "simplifiedDetails") else {
            fatalError("The dequeued cell is not an instance of UITableViewCell")
        }
        if indexPath.section == 0 {
            cell.textLabel?.text = indexPath.row == 0 ? "State" : "Type"
            cell.detailTextLabel?.text = indexPath.row == 0 ? state : type
        } else {
            cell.textLabel?.text = "Order"
            cell.detailTextLabel?.text = order
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}
