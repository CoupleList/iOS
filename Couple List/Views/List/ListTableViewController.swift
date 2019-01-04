//
//  ListTableViewController.swift
//  Couple List
//
//  Created by Kirin Patel on 1/3/19.
//  Copyright © 2019 Kirin Patel. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {
    
    var activities: [CLActivity] = [CLActivity]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let list = CLDefaults.shared.list {
            list.registerDelegate(delegate: self)
            list.observeActivities()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = activities[indexPath.row]
        if let desc = cellData.desc, !desc.isEmpty, let cell = tableView.dequeueReusableCell(withIdentifier: "subtitleActivityCell") {
            cell.textLabel?.text = cellData.title
            cell.detailTextLabel?.text = desc
            return cell
            
        } else if let cell = tableView.dequeueReusableCell(withIdentifier: "defaultActivityCell") {
            cell.textLabel?.text = cellData.title
            return cell
        }
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "")
        cell.textLabel?.text = cellData.title
        return cell
    }
}

extension ListTableViewController: CLListDelegate {
    
    func observersSet() {
        
    }
    
    func observersRemoved() {
        
    }
    
    func activityAdded(activity: CLActivity) {
        activities.append(activity)
        tableView.reloadData()
    }
    
    func activityChanged(activity: CLActivity) {
        if let index = activities.index(where: { $0.id == activity.id }) {
            activities[index] = activity
            tableView.reloadData()
        }
    }
    
    func activityRemoved(id: String) {
        if let index = activities.index(where: { $0.id == id }) {
            activities.remove(at: index)
            tableView.reloadData()
        }
    }
}
