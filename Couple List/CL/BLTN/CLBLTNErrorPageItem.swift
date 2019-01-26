//
//  CLBLTNErrorPageItem.swift
//  Couple List
//
//  Created by Kirin Patel on 1/2/19.
//  Copyright © 2019 Kirin Patel. All rights reserved.
//

import BLTNBoard

class CLBLTNErrorPageItem: CLBLTNPageItem {
    
    override init() {
        super.init(title: "An Error Occurred")
        setup()
    }
    
    init(descriptionText: String) {
        super.init(title: "An Error Occurred")
        setup(descriptionText)
    }
    
    fileprivate func setup(_ descriptionText: String = "An unexpected error has occurred") {
        self.descriptionText = descriptionText
        actionButtonTitle = "Ok"
        actionHandler = { (item: BLTNActionItem) in
            if let manager = item.manager {
                manager.popItem()
            }
        }
    }
}
