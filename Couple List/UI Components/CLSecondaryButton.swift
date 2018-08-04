//
//  SecondaryButton.swift
//  Couple List
//
//  Created by Kirin Patel on 7/4/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit

class CLSecondaryButton: UIButton {
    
    init(title: String) {
        super.init(frame: .zero)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setTitle(title, for: .normal)
        self.tintColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
