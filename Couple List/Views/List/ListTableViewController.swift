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
    var viewableActivities: [CLActivity] = [CLActivity]()
    var selectedActivity: CLActivity?
    var state = "Incomplete"
    var type = "All"
    var order = "Recent"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ambience = true

        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addActivity))
        let sortItem = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(sortActivity))
        navigationItem.rightBarButtonItems = [sortItem, addItem]
        
        if let list = CLDefaults.shared.list {
            list.registerDelegate(delegate: self)
            list.observeActivities()
        } else {
            dismiss(animated: true)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewableActivities.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = viewableActivities[indexPath.row]
        if let desc = cellData.desc, !desc.isEmpty, let cell = tableView.dequeueReusableCell(withIdentifier: "subtitleActivityCell") {
            cell.textLabel?.text = cellData.title
            cell.detailTextLabel?.text = desc
            cell.accessoryType = cellData.completed ? .checkmark : .none
            return cell
            
        } else if let cell = tableView.dequeueReusableCell(withIdentifier: "defaultActivityCell") {
            cell.textLabel?.text = cellData.title
            cell.accessoryType = cellData.completed ? .checkmark : .none
            return cell
        }
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "")
        cell.textLabel?.text = cellData.title
        cell.accessoryType = cellData.completed ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedActivity = viewableActivities[indexPath.row]
        performSegue(withIdentifier: "pushActivityDetailView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let activity = selectedActivity, let destination = segue.destination as? ListActivityDetailView, segue.identifier == "pushActivityDetailView" {
            destination.activity = activity
        } else if let destination = segue.destination as? ListSortingTableViewController, segue.identifier == "pushSortActivityView" {
            destination.state = state
            destination.type = type
            destination.order = order
            destination.delegate = self
        } else if let destination = segue.destination as? ListActivityDetailView, segue.identifier == "pushAddActivityView" {
            destination.title = "Add Activity"
        }
    }
    
    @objc func addActivity() {
        performSegue(withIdentifier: "pushAddActivityView", sender: self)
    }
    
    @objc func sortActivity() {
        performSegue(withIdentifier: "pushSortActivityView", sender: self)
    }
    
    fileprivate func determineViewableActivities() {
        viewableActivities.removeAll()
        activities.forEach { activity in
            var isViewable = true
            
            if state == "Incomplete" && activity.completed { isViewable = false }
            else if state == "Complete" && !activity.completed { isViewable = false }
            
            if type == "Text" { isViewable = false }
            else if type == "Location" { isViewable = false }
            
            if isViewable { viewableActivities.append(activity) }
        }
        if order == "Recent" { viewableActivities.reverse() }
        tableView.reloadData()
    }
}

extension ListTableViewController: CLListDelegate {
    
    func observersSet() {
        
    }
    
    func observersRemoved() {
        
    }
    
    func activityAdded(activity: CLActivity) {
        activities.append(activity)
        determineViewableActivities()
    }
    
    func activityChanged(activity: CLActivity) {
        if let index = activities.index(where: { $0.id == activity.id }) {
            activities[index] = activity
            determineViewableActivities()
        }
    }
    
    func activityRemoved(id: String) {
        if let index = activities.index(where: { $0.id == id }) {
            activities.remove(at: index)
            determineViewableActivities()
        }
    }
}

extension ListTableViewController: ListSortingTableViewControllerDelegate {
    func sortStateChanged(state: String) {
        self.state = state
        determineViewableActivities()
    }
    
    func sortTypeChanged(type: String) {
        self.type = type
        determineViewableActivities()
    }
    
    func sortOrderChanged(order: String) {
        self.order = order
        determineViewableActivities()
    }
}
