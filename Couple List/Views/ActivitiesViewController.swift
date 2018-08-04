//
//  ActivitiesCollectionViewController.swift
//  Couple List
//
//  Created by Kirin Patel on 7/4/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseAnalytics
import FirebaseDatabase
import FirebaseStorage
import GoogleMobileAds

class ActivitiesViewController: UIViewController {
    
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.barStyle = .blackTranslucent
        return searchBar
    }()
    
    let collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        layout.minimumInteritemSpacing = 8.0
        layout.minimumLineSpacing = 8.0
        layout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
        return layout
    }()
    
    var ref: DatabaseReference!
    var storage: Storage!
    var collectionView: UICollectionView!
    var activities = [Activity]()
    static var profileDisplayNames = [String:String]()
    static var profileImages = [String:UIImage]()
    let cellId = "ActivityCollectionViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(named: "MainColor")
        title = "Activities"
        
        ref = Database.database().reference()
        storage = Storage.storage()
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: self.collectionViewLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = nil
        collectionView.register(ActivityCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAdd))
        navigationController?.navigationBar.topItem?.rightBarButtonItem = addButton
        
        setupView()
        loadData()
    }
    
    @objc func handleAdd() {
        navigationController?.pushViewController(AddActivityViewController(), animated: true)
    }
    
    fileprivate func setupView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0.0).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0.0).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0.0).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0.0).isActive = true
    }
    
    fileprivate func loadData() {
        ref.child("lists/\(AppDelegate.settings.listKey)/activities").observe(.value, with: {
            (snapshot) in
            
            self.activities.removeAll()
            
            for child in snapshot.children.allObjects {
                let childSnapshot = child as! DataSnapshot
                
                let title = childSnapshot.childSnapshot(forPath: "title").value as! String
                let desc = childSnapshot.childSnapshot(forPath: "description").value as! String
                let isDone = childSnapshot.childSnapshot(forPath: "done").value as! Bool
                var person: String?
                
                if childSnapshot.childSnapshot(forPath: "person").exists() {
                    person = childSnapshot.childSnapshot(forPath: "person").value as! String
                    
                    if ActivitiesViewController.profileImages.index(forKey: person!) == nil {
                        ActivitiesViewController.profileImages.updateValue(UIImage(named: "ProfileImagePlaceholder")!, forKey: person!)

                        if person! == Auth.auth().currentUser!.uid {
                            ActivitiesViewController.profileDisplayNames.updateValue("You", forKey: person!)
                        } else {
                            self.ref.child("users/\(person!)/displayName").observeSingleEvent(of: .value, with: {
                                (snapshot) in
                                if snapshot.exists() {
                                    ActivitiesViewController.profileDisplayNames.updateValue(snapshot.value as! String, forKey: person!)
                                    
                                    self.collectionView.reloadData()
                                }
                            })
                        }
                        
                        let profileImageRef = self.storage.reference(withPath: "profileImages/\(person!).JPG")
                        profileImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                            if error == nil {
                                ActivitiesViewController.profileImages.updateValue(UIImage(data: data!)!, forKey: person!)
                                
                                self.collectionView.reloadData()
                            }
                        }
                    }
                }
                
                let activity = Activity(key: childSnapshot.key, title: title, desc: desc)!
                activity.isDone = isDone
                if person != nil {
                    activity.person = person
                }
                
                self.activities.append(activity)
            }
            
            self.activities.reverse()
            self.collectionView.reloadData()
        })
    }
}

extension ActivitiesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return activities.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewActivityViewController = ActivityViewController()
        viewActivityViewController.activity = activities[indexPath.row]
        navigationController?.pushViewController(viewActivityViewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ActivityCollectionViewCell
        
        cell.activity = activities[indexPath.row]
        
        return cell
    }
}
