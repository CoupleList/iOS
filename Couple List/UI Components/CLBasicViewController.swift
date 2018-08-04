//
//  CLBasicViewController.swift
//  Couple List
//
//  Created by Kirin Patel on 8/1/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit

class CLBasicViewController: UIViewController {
    
    let titleLabel = CLTitleLabel(text: "")
    
    let descriptionLabel = CLDescriptionLabel(text: "")
    
    let centerStack = CLStackView()
    
    let actionButton = CLSecondaryButton(title: "")
    
    let bottomButton = CLSecondaryButton(title: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(named: "MainColor")
        
        view.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        
        view.addSubview(descriptionLabel)
        descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
        descriptionLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        descriptionLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        
        view.addSubview(centerStack)
        centerStack.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        centerStack.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        centerStack.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.addSubview(actionButton)
        actionButton.topAnchor.constraint(equalTo: centerStack.bottomAnchor, constant: 20).isActive = true
        actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(bottomButton)
        bottomButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        bottomButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func moveView(y: CGFloat) {
        UIView.beginAnimations("moveView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(0.25)
        view.frame = CGRect(origin: CGPoint(x: view.frame.origin.x, y: -y), size: view.frame.size)
        UIView.commitAnimations()
    }
}
