//
//  DescriptionLabel.swift
//  Couple List
//
//  Created by Kirin Patel on 7/4/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit

class CLDescriptionLabel: UILabel {
    
    init(text: String) {
        super.init(frame: .zero)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.text = text
        self.numberOfLines = 0
        self.textColor = .white
        self.textAlignment = .center
        self.font = UIFont.systemFont(ofSize: 17, weight: .light)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
