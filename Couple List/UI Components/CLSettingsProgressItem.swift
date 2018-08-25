//
//  CLSettingsProgressItem.swift
//  Couple List
//
//  Created by Kirin Patel on 8/24/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit

class CLSettingsProgressItem: UIView {
    
    fileprivate let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = UIColor.init(named: "MainColor")
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    
    fileprivate let detailsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        label.numberOfLines = 1
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)
        return label
    }()
    
    fileprivate let progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progress = 0
        return progressView
    }()
    
    var iconImage: UIImage! {
        didSet {
            iconImageView.image = iconImage
        }
    }
    
    var title: String! {
        didSet {
            titleLabel.text = title
        }
    }
    
    var details: String! {
        didSet {
            detailsLabel.text = details
        }
    }
    
    var progress: Float! {
        didSet {
            if progress == 1 {
                detailsLabel.isHidden = false
                progressView.isHidden = true
            } else {
                progressView.progress = progress
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        
        addSubview(iconImageView)
        iconImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        iconImageView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        iconImageView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
        iconImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: iconImageView.topAnchor, constant: 0).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: iconImageView.rightAnchor, constant: 10).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        
        addSubview(progressView)
        progressView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0).isActive = true
        progressView.bottomAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 0).isActive = true
        progressView.leftAnchor.constraint(equalTo: iconImageView.rightAnchor, constant: 10).isActive = true
        progressView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        
        addSubview(detailsLabel)
        detailsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0).isActive = true
        detailsLabel.bottomAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 0).isActive = true
        detailsLabel.leftAnchor.constraint(equalTo: iconImageView.rightAnchor, constant: 10).isActive = true
        detailsLabel.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
    }
}
