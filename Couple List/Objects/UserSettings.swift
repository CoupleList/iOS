//
//  UserSettings.swift
//  Couple List
//
//  Created by Kirin Patel on 6/16/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit

class UserSettings: NSObject {
    
    var listKey: String
    var listCode: String
    
    init?(listKey: String, listCode: String) {
        self.listKey = listKey
        self.listCode = listCode
    }
    
    class func generateFromLink(link: String) -> UserSettings {
        let link = link.replacingOccurrences(of: "%3D", with: "=")
        let listKey = link.split(separator: "?")[1].split(separator: "=")[1]
        let listCode = link.split(separator: "?")[2].split(separator: "=")[1].split(separator: "&")[0]
        
        return UserSettings(listKey: listKey.description, listCode: listCode.description)!
    }
    
    func reset() {
        listKey = ""
        listCode = ""
    }
}
