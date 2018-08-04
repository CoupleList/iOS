//
//  CLStackView.swift
//  Couple List
//
//  Created by Kirin Patel on 8/2/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit

class CLStackView: UIStackView {
    
    init() {
        super.init(frame: .zero)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.axis = .vertical
        self.distribution = .fillProportionally
        self.spacing = 8
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
