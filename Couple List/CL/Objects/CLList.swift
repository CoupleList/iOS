//
//  CLList.swift
//  Couple List
//
//  Created by Kirin Patel on 1/3/19.
//  Copyright © 2019 Kirin Patel. All rights reserved.
//

import FirebaseDatabase

protocol CLListDelegate: class {
    func observersSet()
    func observersRemoved()
    func activityAdded(activity: CLActivity)
    func activityChanged(activity: CLActivity)
    func activityRemoved(id: String)
}

class CLList {
    
    var key: String
    var code: String
    var displaysAds: Bool = true
    private var delegates: [CLListDelegate] = [CLListDelegate]()
    private var addedObserver: UInt?
    private var changedObserver: UInt?
    private var removedObserver: UInt?
    
    init(key: String, code: String) {
        self.key = key
        self.code = code
        let ref = Database.database().reference(withPath: "lists/\(key)/hasAds")
        ref.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                if let displaysAds = snapshot.childSnapshot(forPath: "noAds").value as? Bool {
                    self.displaysAds = !displaysAds
                }
            }
        }
    }
    
    func createActivity(title: String, details: String = "") {
        let ref = Database.database().reference(withPath: "lists/\(key)")
        let id = ref.childByAutoId().key
        if let id = id {
            ref.child("activities/\(id)").setValue([
                "title": title,
                "description": details,
                "done": false
                ])
        }
    }
    
    func observeActivities() {
        removeActivitiesObserver()
        let ref = Database.database().reference(withPath: "lists/\(key)/activities")
        delegates.forEach { $0.observersSet() }
        addedObserver = ref.observe(.childAdded, with: { snapshot in
            if let activity = self.createActivityFromSnapshot(ref: ref, snapshot: snapshot) {
                self.delegates.forEach { $0.activityAdded(activity: activity) }
            }
        })
        changedObserver = ref.observe(.childChanged, with: { snapshot in
            if let activity = self.createActivityFromSnapshot(ref: ref, snapshot: snapshot) {
                self.delegates.forEach { $0.activityChanged(activity: activity) }
            }
        })
        removedObserver = ref.observe(.childRemoved, with: { snapshot in
            self.delegates.forEach { $0.activityRemoved(id: snapshot.key) }
        })
    }
    
    func removeActivitiesObserver() {
        let ref = Database.database().reference(withPath: "lists/\(key)/activities")
        if let observer = addedObserver {
            ref.removeObserver(withHandle: observer)
        }
        if let observer = changedObserver {
            ref.removeObserver(withHandle: observer)
        }
        if let observer = removedObserver {
            ref.removeObserver(withHandle: observer)
        }
        delegates.forEach { $0.observersRemoved() }
    }
    
    func registerDelegate(delegate: CLListDelegate) {
        delegates.append(delegate)
    }
    
    func removeDelegate(delegate: CLListDelegate) {
        if let index = delegates.index(where: { $0 === delegate }) {
            delegates.remove(at: index)
        }
    }
    
    fileprivate func createActivityFromSnapshot(ref: DatabaseReference, snapshot: DataSnapshot) -> CLActivity? {
        let id = snapshot.key
        if let title = snapshot.childSnapshot(forPath: "title").value as? String {
            let desc = snapshot.childSnapshot(forPath: "description").value as? String ?? ""
            let completed = snapshot.childSnapshot(forPath: "done").value as? Bool ?? false
            return CLActivity(listRef: ref,
                              id: id,
                              title: title,
                              desc: desc,
                              completed: completed)
        } else {
            return nil
        }
    }
}
