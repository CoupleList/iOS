//
//  HistoryViewController.swift
//  Couple List
//
//  Created by Kirin Patel on 6/17/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class HistoryTableViewController: UITableViewController {
    
    var activityHistory = [ActivityHistory]()
    let cellIdentifier = "ActivityHistoryCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(named: "MainColor")
        title = "History"
        
        tableView.register(ActivityHistoryTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        loadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activityHistory.count
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ActivityHistoryTableViewCell
        
        cell.activityHistory = activityHistory[indexPath.row]
        
        return cell
    }
    
    fileprivate func loadData() {
        Database.database().reference().child("lists/\(AppDelegate.settings.listKey)/history").queryLimited(toLast: 25).observe(.value, with: {
            (snapshot) in
            self.activityHistory = [ActivityHistory]()
            
            for child in snapshot.children.allObjects {
                let childSnapshot = child as! DataSnapshot
                
                var before, after: Activity
                
                if childSnapshot.childSnapshot(forPath: "time").exists() && childSnapshot.childSnapshot(forPath: "state").exists() {
                    let history = ActivityHistory(time: childSnapshot.childSnapshot(forPath: "time").value as! Int, state: childSnapshot.childSnapshot(forPath: "state").value as! Int)!
                    
                    if childSnapshot.childSnapshot(forPath: "before").exists() {
                        before = Activity(key: childSnapshot.key, title: childSnapshot.childSnapshot(forPath: "before").childSnapshot(forPath: "title").value as! String, desc: childSnapshot.childSnapshot(forPath: "before").childSnapshot(forPath: "description").value as! String)!
                        before.isDone = childSnapshot.childSnapshot(forPath: "before").childSnapshot(forPath: "done").value as! Bool
                        history.before = before
                    }
                    
                    if childSnapshot.childSnapshot(forPath: "after").exists() {
                        after = Activity(key: childSnapshot.key, title: childSnapshot.childSnapshot(forPath: "after").childSnapshot(forPath: "title").value as! String, desc: childSnapshot.childSnapshot(forPath: "after").childSnapshot(forPath: "description").value as! String)!
                        after.isDone = childSnapshot.childSnapshot(forPath: "after").childSnapshot(forPath: "done").value as! Bool
                        history.after = after
                    }
                    
                    self.activityHistory.append(history)
                }
            }
            
            self.activityHistory = self.activityHistory.sorted(by: { $0.time > $1.time })
            self.tableView.reloadData()
        })
    }
}
