//
//  ListActivityDetailView.swift
//  Couple List
//
//  Created by Kirin Patel on 1/3/19.
//  Copyright © 2019 Kirin Patel. All rights reserved.
//

import UIKit

class ListActivityDetailView: UIViewController {
    
    var activity: CLActivity? {
        didSet {
            if let activity = activity {
                title = activity.title
            }
        }
    }
}
