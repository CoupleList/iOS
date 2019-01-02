//
//  ActivityTableViewController.swift
//  Couple List
//
//  Created by Kirin Patel on 8/5/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth
import FirebaseAnalytics
import FirebaseDatabase
import FirebaseStorage
import GoogleMobileAds

class ActivitiesTableViewController: UITableViewController {
    
    var ref: DatabaseReference!
    var storage: Storage!
    var activities = [Activity]()
    var animatedRows = [Int]()
    var state = "Incompleted"
    var type = "All"
    let cellIdentifier = "ActivityTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        loadData()
    }
    
    @objc func handleAdd() {
        navigationController?.pushViewController(AddActivityViewController(), animated: true)
    }
    
    @objc func handleOrganize() {
        let sortView = ActivitiesTableSortViewController()
        sortView.selectedState = state
        sortView.selectedType = type
        sortView.delegate = self
        navigationController?.pushViewController(sortView, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if animatedRows.contains(indexPath.row) {
            return
        }
        
        animatedRows.append(indexPath.row)
        
        cell.alpha = 0
        cell.transform = CGAffineTransform(translationX: 0, y: 20)
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0,
                       initialSpringVelocity: 0,
                       options: [ .preferredFramesPerSecond60, .allowUserInteraction ],
                       animations: {
                        cell.alpha = 1
                        cell.transform = CGAffineTransform(translationX: 0, y: 0)
        })
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let activityView = ActivityViewController()
        activityView.activity = activities[indexPath.row]
        navigationController?.pushViewController(activityView, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ActivityTableViewCell
        
        cell.activity = activities[indexPath.row]
        cell.delegate = self
        cell.selectionStyle = .none
        
        return cell
    }
    
    fileprivate func setupView() {
        view.backgroundColor = UIColor.init(named: "MainColor")
        title = "Activities"
        tableView.separatorStyle = .none
        tableView.register(ActivityTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.estimatedRowHeight = 70.0
        
        ref = Database.database().reference()
        storage = Storage.storage()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAdd))
        let organizeButton = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(handleOrganize))
        navigationController?.navigationBar.topItem?.rightBarButtonItems = [
            organizeButton,
            addButton
            ]
    }
    
    fileprivate func handleActivityData(snapshot: DataSnapshot) {
        for child in snapshot.children.allObjects {
            let childSnapshot = child as! DataSnapshot
            
            let title = childSnapshot.childSnapshot(forPath: "title").value as! String
            let desc = childSnapshot.childSnapshot(forPath: "description").value as! String
            let isDone = childSnapshot.childSnapshot(forPath: "done").value as! Bool
            let activity = Activity(key: childSnapshot.key, title: title, desc: desc)!
            activity.isDone = isDone
            
            if self.state == "Incompleted" && activity.isDone {
                continue
            } else if self.state == "Completed" && !activity.isDone {
                continue
            }
            
            if childSnapshot.childSnapshot(forPath: "person").exists() {
                if let person = childSnapshot.childSnapshot(forPath: "person").value as? String {
                    activity.person = person
                    if CL.shared.profileImages.index(forKey: person) == nil {
                        CL.shared.profileImages.updateValue(UIImage(named: "profilePicture")!, forKey: person)
                        
                        if person == Auth.auth().currentUser!.uid {
                            CL.shared.profileDisplayNames.updateValue("You", forKey: person)
                        } else {
                            self.ref.child("users/\(person)/displayName").observeSingleEvent(of: .value, with: {
                                (snapshot) in
                                if snapshot.exists() {
                                    CL.shared.profileDisplayNames.updateValue(snapshot.value as! String, forKey: person)
                                    
                                    self.tableView.reloadData()
                                }
                            })
                        }
                        
                        let profileImageRef = self.storage.reference(withPath: "profileImages/\(person).JPG")
                        profileImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                            if error == nil {
                                CL.shared.profileImages.updateValue(UIImage(data: data!)!, forKey: person)
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
            
            if childSnapshot.childSnapshot(forPath: "location").exists() {
                if let lat = childSnapshot.childSnapshot(forPath: "location/lat").value as? Double,
                    let long = childSnapshot.childSnapshot(forPath: "location/long").value as? Double {
                    let location = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long)))
                    activity.location = location
                }
            }
            
            if self.type == "Images" && activity.image == nil {
                continue
            } else if self.type == "Locations" && activity.location == nil {
                continue
            }
            
            self.activities.append(activity)
        }
    }
    
    fileprivate func loadData() {
        ref.child("lists/\(CL.shared.userSettings.listKey)/activities").observe(.value, with: { snapshot in
            self.activities.removeAll()
            self.animatedRows.removeAll()
            
            self.handleActivityData(snapshot: snapshot)
            
            self.activities.reverse()
            self.tableView.reloadData()
        })
    }
    
    fileprivate func refreshData() {
        ref.child("lists/\(CL.shared.userSettings.listKey)/activities").observeSingleEvent(of: .value, with: { snapshot in
            self.activities.removeAll()
            self.animatedRows.removeAll()
            
            self.handleActivityData(snapshot: snapshot)
            
            self.activities.reverse()
            self.tableView.reloadData()
        })
    }
}

extension ActivitiesTableViewController: ActivityTableViewCellDelegate {
    
    func getDirectionsForActivity(placemark: CLPlacemark) {
        CL.generateDirectionsAlert(placemark: placemark) { alert in
            self.present(alert, animated: true)
        }
    }
}

extension ActivitiesTableViewController: ActivitiesTableSortViewControllerDelegate {
    func selectedNewStateOrType(state: String, type: String) {
        var changed = false
        
        if self.state != state {
            changed = true
            self.state = state
        }
        
        if self.type != type {
            changed = true
            self.type = type
        }
        
        if changed {
            refreshData()
        }
    }
}
