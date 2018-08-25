//
//  LocationTableViewCell.swift
//  Couple List
//
//  Created by Kirin Patel on 8/25/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    
    let addressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.init(named: "MainColor")
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupView() {
        contentView.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 18.5).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8.0).isActive = true
        
        contentView.addSubview(addressLabel)
        addressLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4.0).isActive = true
        addressLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0).isActive = true
        addressLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 18.5).isActive = true
        addressLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8.0).isActive = true
    }
}
