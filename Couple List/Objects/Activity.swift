//
//  Activity.swift
//  Couple List
//
//  Created by Kirin Patel on 6/3/17.
//  Copyright © 2017 Kirin Patel. All rights reserved.
//

import UIKit
import MapKit

class Activity: NSObject {
    
    var key: String
    var title: String
    var desc: String
    var person: String?
    var image: UIImage?
    var location: MKPlacemark?
    var date: Date?
    var isDone: Bool
    
    init?(key: String, title: String, desc: String) {
        guard !key.isEmpty && !title.isEmpty else {
            return nil
        }
        
        self.key = key
        self.title = title;
        self.desc = desc;
        self.isDone = false;
    }
}
