//
//  CLBLTNPageItem.swift
//  Couple List
//
//  Created by Kirin Patel on 1/2/19.
//  Copyright © 2019 Kirin Patel. All rights reserved.
//

import BLTNBoard

class CLBLTNPageItem: BLTNPageItem {
    
    override init() {
        super.init()
        setup()
    }
    
    override init(title: String) {
        super.init(title: title)
        setup()
    }
    
    fileprivate func setup() {
        requiresCloseButton = false
        isDismissable = false
    }
}
