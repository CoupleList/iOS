//
//  CL.swift
//  Couple List
//
//  Created by Kirin Patel on 8/24/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import Foundation
import UIKit

class CL {
    
    static let shared = CL()
    
    var userSettings: UserSettings = UserSettings.init(listKey: "", listCode: "")!
    var profileDisplayNames = [String:String]()
    var profileImages = [String:UIImage]()
    
    func setNoAds(noAds: Bool) {
        UserDefaults.standard.set(noAds, forKey: "noAds")
    }
    
    func noAds() -> Bool {
        return UserDefaults.standard.bool(forKey: "noAds")
    }
}
