//
//  ViewActivityViewController.swift
//  Couple List
//
//  Created by Kirin Patel on 7/7/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseAnalytics
import FirebaseDatabase
import FirebaseStorage

class ActivityViewController: UIViewController {
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.indicatorStyle = .black
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    let clCard = CLCard()
    
    let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Delete", for: .normal)
        button.tintColor = UIColor.init(named: "AppleRed")
        button.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
        return button
    }()
    
    let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Edit", for: .normal)
        button.addTarget(self, action: #selector(handleEdit), for: .touchUpInside)
        return button
    }()
    
    var ref: DatabaseReference!
    var storage: Storage!
    
    var activity: Activity! {
        didSet {
            clCard.activity = activity
            editButton.isHidden = activity.isDone
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(named: "MainColor")
        title = "Activity Details"
        
        ref = Database.database().reference()
        
        setupView()
    }
    
    @objc func handleDelete() {
        let alert = UIAlertController(title: "Delete Activity?", message: "Deleting this activity means that you and your S.O. can no longer track progress for it. This is a destructive process and is not reversable.", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete Activity", style: .destructive, handler: {
            _ in
            self.ref.child("lists/\(AppDelegate.settings.listKey)/activities/\(self.activity.key)").removeValue()
            self.navigationController!.popViewController(animated: true)
        })
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func handleEdit() {
        let editActivityViewController = EditActivityViewController()
        editActivityViewController.activity = activity
        editActivityViewController.delegate = self
        navigationController?.pushViewController(editActivityViewController, animated: true)
    }
    
    fileprivate func setupView() {
        view.addSubview(scrollView)
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        scrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        
        scrollView.addSubview(clCard)
        clCard.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0.0).isActive = true
        clCard.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0.0).isActive = true
        clCard.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0.0).isActive = true
        clCard.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0.0).isActive = true
        
        clCard.bottomView.addSubview(deleteButton)
        deleteButton.topAnchor.constraint(equalTo: clCard.bottomView.topAnchor, constant: 0.0).isActive = true
        deleteButton.bottomAnchor.constraint(equalTo: clCard.bottomView.bottomAnchor, constant: 0.0).isActive = true
        deleteButton.leftAnchor.constraint(equalTo: clCard.bottomView.leftAnchor, constant: 10.0).isActive = true
        
        clCard.bottomView.addSubview(editButton)
        editButton.topAnchor.constraint(equalTo: clCard.bottomView.topAnchor, constant: 0.0).isActive = true
        editButton.bottomAnchor.constraint(equalTo: clCard.bottomView.bottomAnchor, constant: 0.0).isActive = true
        editButton.rightAnchor.constraint(equalTo: clCard.bottomView.rightAnchor, constant: -10.0).isActive = true
        
        scrollView.bounds = view.bounds
        scrollView.contentSize = CGSize(width: view.bounds.width, height: .infinity)
    }
}

extension ActivityViewController: EditActivityViewControllerDelegate {
    
    func activityWasEdited(_ activity: Activity) {
        self.activity = activity
    }
}
