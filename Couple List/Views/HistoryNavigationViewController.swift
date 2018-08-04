//
//  HistoryNavigationViewController.swift
//  Couple List
//
//  Created by Kirin Patel on 7/5/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit

class HistoryNavigationViewController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.prefersLargeTitles = true
        navigationBar.barStyle = .black
        navigationBar.tintColor = .white
        
        pushViewController(HistoryTableViewController(), animated: true)
    }
}
