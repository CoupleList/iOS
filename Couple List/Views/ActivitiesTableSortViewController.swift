//
//  ActivitiesTableSortViewController.swift
//  Couple List
//
//  Created by Kirin Patel on 10/14/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit

protocol ActivitiesTableSortViewControllerDelegate: class {
    func selectedNewStateOrType(state: String, type: String)
}

class ActivitiesTableSortViewController: UITableViewController {
    
    
    let sections = ["Activity State", "Activity Type"]
    let filterOptions = [
        ["All", "Incompleted", "Completed"],
        ["All", "Locations"]
    ]
    var delegate: ActivitiesTableSortViewControllerDelegate?
    var selectedState = "Incompleted" {
        didSet {
            tableView.reloadData()
        }
    }
    var selectedType = "All" {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(named: "MainColor")
        title = "Sort List"
        
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let delegate = delegate {
            delegate.selectedNewStateOrType(state: selectedState, type: selectedType)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterOptions[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "sortCell")
        
        let option: String = filterOptions[indexPath.section][indexPath.row]
        let selected = (indexPath.section == 0 && option == selectedState) || (indexPath.section == 1 && option == selectedType)
        
        cell.backgroundColor = selected ? .white : UIColor(named: "MainColor")
        
        if let label = cell.textLabel {
            label.text = option
            label.textColor = selected ? .black : .white
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            selectedState = filterOptions[0][indexPath.row]
        } else if indexPath.section == 1 {
            selectedType = filterOptions[1][indexPath.row]
        }
        tableView.reloadData()
    }
}
