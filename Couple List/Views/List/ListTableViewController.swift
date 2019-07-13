//
//  ListTableViewController.swift
//  Couple List
//
//  Created by Kirin Patel on 1/3/19.
//  Copyright © 2019 Kirin Patel. All rights reserved.
//

import UIKit
import BLTNBoard

class ListTableViewController: UITableViewController {
    
    lazy var activityBulletinManager: CLBLTNItemManager = {
        return CLBLTNItemManager(rootItem: CLBLTNErrorPageItem(descriptionText: "Unable to preform this action."))
    }()
    
    var activities: [CLActivity] = [CLActivity]()
    var viewableActivities: [CLActivity] = [CLActivity]()
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
        let activity = viewableActivities[indexPath.row]
        activityBulletinManager = {
            return CLBLTNItemManager(rootItem: self.generateEditActivityPageItem(activity: activity))
        }()
        activityBulletinManager.show(above: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ListSortingTableViewController, segue.identifier == "pushSortActivityView" {
            destination.state = state
            destination.type = type
            destination.order = order
            destination.delegate = self
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let activity = viewableActivities[indexPath.row]
        
        let complete = UITableViewRowAction(style: .normal, title: "Complete") { action, index in
            activity.complete()
        }
        complete.backgroundColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1.0)
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            activity.delete()
        }
        delete.backgroundColor = UIColor(red: 1.0, green: 59/255, blue: 48/255, alpha: 1.0)
        
        if (activity.completed) {
            return [delete]
        } else {
            return [delete, complete]
        }
    }
    
    @objc func addActivity() {
        activityBulletinManager = {
            return CLBLTNItemManager(rootItem: self.generateAddActivityPageItem())
        }()
        activityBulletinManager.show(above: self)
    }
    
    @objc func sortActivity() {
        performSegue(withIdentifier: "pushSortActivityView", sender: self)
    }
    
    fileprivate func determineViewableActivities() {
        viewableActivities.removeAll()
        for activity in activities {
            if state == "Incomplete" && activity.completed { continue }
            else if state == "Complete" && !activity.completed { continue }
            
            if type == "Text" { continue }
            else if type == "Location" { continue }
            
            viewableActivities.append(activity)
        }
        if order == "Recent" { viewableActivities.reverse() }
        tableView.reloadData()
    }
    
    fileprivate func generateAddActivityPageItem(title: String = "", details: String = "") -> CLBLTNAddActivityPageItem {
        let page = CLBLTNAddActivityPageItem(title: title, details: details)
        page.actionHandler = { (item: BLTNActionItem) in
            let title = page.titleField.text ?? ""
            let details = page.detailsField.text ?? ""
            if title.count > 0 {
                page.shouldStartWithActivityIndicator = true
                CLDefaults.shared.list?.createActivity(title: title, details: details)
                if let manager = item.manager {
                    manager.dismissBulletin()
                }
            } else if let manager = item.manager {
                let errorPage = CLBLTNErrorPageItem(descriptionText: "A title is required in order to create an activity")
                manager.push(item: errorPage)
            }
        }
        return page
    }
    
    fileprivate func generateEditActivityPageItem(activity: CLActivity) -> CLBLTNEditActivityPageItem {
        let page = CLBLTNEditActivityPageItem(activity: activity)
        page.actionHandler = { (item: BLTNActionItem) in
            activity.title = page.titleField.text ?? ""
            activity.desc = page.detailsField.text ?? ""
            if activity.title.count > 0 {
                page.shouldStartWithActivityIndicator = true
                activity.update()
                if let manager = item.manager {
                    manager.dismissBulletin()
                }
            } else if let manager = item.manager {
                let errorPage = CLBLTNErrorPageItem(descriptionText: "A title is required in order to update an activity")
                manager.push(item: errorPage)
            }
        }
        return page
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
