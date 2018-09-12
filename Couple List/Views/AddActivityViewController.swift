//
//  AddActivityViewController.swift
//  Couple List
//
//  Created by Kirin Patel on 7/4/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth
import FirebaseAnalytics
import FirebaseDatabase

class AddActivityViewController: UIViewController {
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.indicatorStyle = .black
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    let clEditableCard = CLEditableCard()
    
    let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add", for: .normal)
        button.setTitleColor(UIColor.init(named: "MainColor"), for: .normal)
        button.addTarget(self, action: #selector(handleAdd), for: .touchUpInside)
        return button
    }()
    
    var ref: DatabaseReference!
    var activity: Activity! {
        didSet {
            clEditableCard.activity = activity
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(named: "MainColor")
        title = "Add Activity"
        
        ref = Database.database().reference()
        clEditableCard.delegate = self
        
        let key = ref.child("lists/\(CL.shared.userSettings.listKey)/activities").childByAutoId().key
        let newActivity = Activity(key: key, title: "Activity Title", desc: "Activity Description")!
        newActivity.person = Auth.auth().currentUser!.uid
        activity = newActivity
        
        setupView()
    }
    
    @objc func handleAdd() {
        view.endEditing(true)
        
        activity = clEditableCard.activity
        if activity.title != "Activity Title" {
            let desc = activity.desc != "Activity Description" ? activity.desc : ""
            if let location = activity.location {
                ref.child("lists/\(CL.shared.userSettings.listKey)/activities/\(activity.key)").setValue([
                    "title": activity.title,
                    "description": desc,
                    "location": [
                        "lat": location.coordinate.latitude,
                        "long": location.coordinate.longitude
                    ],
                    "done": false,
                    "person": Auth.auth().currentUser!.uid
                    ])
            } else {
                ref.child("lists/\(CL.shared.userSettings.listKey)/activities/\(activity.key)").setValue(["title": activity.title, "description": desc, "done": false, "person": Auth.auth().currentUser!.uid])
            }
            
            navigationController?.popViewController(animated: true)
        } else {
            let alert = UIAlertController(title: "Missing Title", message: "A title is required to create an activity.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    fileprivate func setupView() {
        view.addSubview(scrollView)
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        scrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        
        scrollView.addSubview(clEditableCard)
        clEditableCard.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0).isActive = true
        clEditableCard.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0).isActive = true
        clEditableCard.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        clEditableCard.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        
        clEditableCard.bottomView.addSubview(addButton)
        addButton.topAnchor.constraint(equalTo: clEditableCard.bottomView.topAnchor, constant: 0).isActive = true
        addButton.bottomAnchor.constraint(equalTo: clEditableCard.bottomView.bottomAnchor, constant: 0).isActive = true
        addButton.rightAnchor.constraint(equalTo: clEditableCard.bottomView.rightAnchor, constant: -10).isActive = true
        
        scrollView.bounds = view.bounds
        scrollView.contentSize = CGSize(width: view.bounds.width, height: .infinity)
    }
}

extension AddActivityViewController: CLEditableCardDelegate {
    
    func userWantsToAddLocation() {
        let mapKitLocationFinder = MapKitLocationFinder()
        mapKitLocationFinder.clEditableCardDelegate = self
        navigationController?.pushViewController(mapKitLocationFinder, animated: true)
    }
    
    func userWantsToChangeLocation() {
        let alert = UIAlertController(title: "Change Activity Location?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Change", style: .default) { _ in
            let mapKitLocationFinder = MapKitLocationFinder()
            mapKitLocationFinder.clEditableCardDelegate = self
            self.navigationController?.pushViewController(mapKitLocationFinder, animated: true)
        })
        present(alert, animated: true)
    }
    
    func userWantsToRemoveLocation() {
        let alert = UIAlertController(title: "Remove Activity Location?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { _ in
            self.activity.location = nil
            self.clEditableCard.activity = self.activity
        })
        present(alert, animated: true)
    }
    
    func userAddedLocation(location: MKPlacemark) {
        activity.location = location
        clEditableCard.activity = activity
    }
}
