//
//  EditActivityViewController.swift
//  Couple List
//
//  Created by Kirin Patel on 7/7/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import MapKit
import StoreKit
import FirebaseAuth
import FirebaseAnalytics
import FirebaseDatabase
import FirebaseStorage

protocol EditActivityViewControllerDelegate: class {
    func activityWasEdited(_ activity: Activity)
}

class EditActivityViewController: UIViewController {
    
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
    
    let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Save", for: .normal)
        button.setTitleColor(UIColor.init(named: "MainColor"), for: .normal)
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return button
    }()
    
    let completeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Complete", for: .normal)
        button.setTitleColor(UIColor.init(named: "MainColor"), for: .normal)
        button.addTarget(self, action: #selector(handleComplete), for: .touchUpInside)
        return button
    }()
    
    var ref: DatabaseReference!
    var delegate: EditActivityViewControllerDelegate!
    var activity: Activity! {
        didSet {
            clEditableCard.activity = activity
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(named: "MainColor")
        title = "Edit Activity"
        
        ref = Database.database().reference()
        clEditableCard.delegate = self
        
        setupView()
    }
    
    @objc func handleSave() {
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
                ref.child("lists/\(CL.shared.userSettings.listKey)/activities/\(activity.key)").setValue([
                    "title": activity.title,
                    "description": desc,
                    "location": nil,
                    "done": false,
                    "person": Auth.auth().currentUser!.uid
                    ])
            }
            
            delegate.activityWasEdited(activity)
            navigationController?.popViewController(animated: true)
        } else {
            let alert = UIAlertController(title: "Missing Activity Title", message: "A title is required in order to create an activity.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    @objc func handleComplete() {
        let alert = UIAlertController(title: "Complete Activity", message: "Completing \"\(activity.title)\" will signify progress made with your partner, but, the activity will no longer be configurable.", preferredStyle: .actionSheet)
        
        let completeAction = UIAlertAction(title: "Complete", style: .default, handler: { _ in
            self.activity = self.clEditableCard.activity
            self.activity.isDone = true
            
            self.ref.child("lists/\(CL.shared.userSettings.listKey)/activities/\(self.activity.key)").updateChildValues(["title": self.activity.title, "description": self.activity.desc, "done": self.activity.isDone, "person": self.activity.person!, "lastEditor": Auth.auth().currentUser!.uid])
            
            self.delegate.activityWasEdited(self.activity)
            self.navigationController?.popViewController(animated: true)
            SKStoreReviewController.requestReview()
        })
        alert.addAction(completeAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.popoverPresentationController?.sourceView = completeButton
        alert.popoverPresentationController?.sourceRect = completeButton.bounds
        
        present(alert, animated: true)
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
        
        clEditableCard.bottomView.addSubview(completeButton)
        completeButton.topAnchor.constraint(equalTo: clEditableCard.bottomView.topAnchor, constant: 0).isActive = true
        completeButton.bottomAnchor.constraint(equalTo: clEditableCard.bottomView.bottomAnchor, constant: 0).isActive = true
        completeButton.leftAnchor.constraint(equalTo: clEditableCard.bottomView.leftAnchor, constant: 10).isActive = true
        
        clEditableCard.bottomView.addSubview(saveButton)
        saveButton.topAnchor.constraint(equalTo: clEditableCard.bottomView.topAnchor, constant: 0).isActive = true
        saveButton.bottomAnchor.constraint(equalTo: clEditableCard.bottomView.bottomAnchor, constant: 0).isActive = true
        saveButton.rightAnchor.constraint(equalTo: clEditableCard.bottomView.rightAnchor, constant: -10).isActive = true
        
        scrollView.bounds = view.bounds
        scrollView.contentSize = CGSize(width: view.bounds.width, height: .infinity)
    }
}

extension EditActivityViewController: CLEditableCardDelegate {
    
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
