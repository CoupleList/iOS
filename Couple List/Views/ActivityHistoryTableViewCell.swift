//
//  ActivityHistoryTableViewCell.swift
//  Couple List
//
//  Created by Kirin Patel on 7/5/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit

class ActivityHistoryTableViewCell: UITableViewCell {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    let stateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .white
        return label
    }()
    
    var activityHistory: ActivityHistory! {
        didSet {
            switch activityHistory.state {
            case .created:
                titleLabel.text = activityHistory.after?.title
                stateLabel.text = "Created"
                break
            case .deleted:
                titleLabel.text = activityHistory.before?.title
                stateLabel.text = "Deleted"
                break
            case .edited:
                titleLabel.text = activityHistory.before?.title
                stateLabel.text = "Edited"
                break
            case .completed:
                titleLabel.text = activityHistory.after?.title
                stateLabel.text = "Finished"
                break
            }
        }
    }
    
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
        
        contentView.addSubview(stateLabel)
        stateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4.0).isActive = true
        stateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0).isActive = true
        stateLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 18.5).isActive = true
        stateLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8.0).isActive = true
    }
}

