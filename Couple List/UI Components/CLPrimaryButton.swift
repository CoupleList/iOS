//
//  MainButton.swift
//  Couple List
//
//  Created by Kirin Patel on 7/4/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit

class CLPrimaryButton: UIButton {
    
    init(title: String) {
        super.init(frame: .zero)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setTitle(title, for: .normal)
        self.tintColor = UIColor.init(named: "MainColor")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
