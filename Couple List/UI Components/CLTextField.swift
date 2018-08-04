//
//  CLTextField.swift
//  Couple List
//
//  Created by Kirin Patel on 8/1/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit

class CLTextField: UITextField {
    
    init(placeHolder: String) {
        super.init(frame: .zero)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.placeholder = placeHolder
        self.backgroundColor = .white
        self.layer.cornerRadius = 6
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
