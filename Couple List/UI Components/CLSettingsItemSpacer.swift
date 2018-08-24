//
//  CLSettingsItemSpacer.swift
//  Couple List
//
//  Created by Kirin Patel on 8/23/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit

class CLSettingsItemSpacer: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        
        heightAnchor.constraint(equalToConstant: 10).isActive = true
    }
}
