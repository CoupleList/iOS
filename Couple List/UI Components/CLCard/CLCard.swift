//
//  CLCard.swift
//  Couple List
//
//  Created by Kirin Patel on 8/6/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit

class CLCard: UIView {
    
    fileprivate let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    fileprivate let headerView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    fileprivate let centerView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    fileprivate let bottomView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        stackView.spacing = 8
        return stackView
    }()
    
    fileprivate lazy var headerViewTopConstraint = headerView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 0)
    fileprivate lazy var centerViewTopConstraint = centerView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0)
    fileprivate lazy var bottomViewTopConstraint = bottomView.topAnchor.constraint(equalTo: centerView.bottomAnchor, constant: 0)
    
    var headerContent: [UIView] = [] {
        willSet {
            headerView.arrangedSubviews.forEach { headerView.removeArrangedSubview($0) }
            newValue.forEach {
                headerView.addArrangedSubview($0)
            }
            headerViewTopConstraint.constant = newValue.count > 0 ? 4 : 0
            headerView.setNeedsUpdateConstraints()
            headerView.setNeedsLayout()
            headerView.setNeedsDisplay()
        }
    }
    var centerContent: [UIView] = [] {
        willSet {
            centerViewTopConstraint.constant = newValue.count > 0 ? 4 : 0
            centerView.setNeedsLayout()
        }
    }
    var bottomContent: [UIView] = [] {
        willSet {
            bottomView.arrangedSubviews.forEach { bottomView.removeArrangedSubview($0) }
            newValue.forEach {
                bottomView.addArrangedSubview($0)
            }
            bottomViewTopConstraint.constant = newValue.count > 0 ? 4 : 0
            bottomView.setNeedsUpdateConstraints()
            bottomView.setNeedsLayout()
            bottomView.setNeedsDisplay()
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        setupView()
    }
    
    init(headerContent: [UIView], centerContent: [UIView], bottomContent: [UIView]) {
        super.init(frame: .zero)
        
        setupView()
        
        self.headerContent = headerContent
        self.centerContent = centerContent
        self.bottomContent = bottomContent
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.init(named: "MainColor")
        
        addSubview(cardView)
        cardView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        cardView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        cardView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        cardView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        
        cardView.addSubview(headerView)
        headerViewTopConstraint.isActive = true
        headerView.leftAnchor.constraint(equalTo: cardView.leftAnchor, constant: 4).isActive = true
        headerView.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: -4).isActive = true
        
        cardView.addSubview(centerView)
        centerViewTopConstraint.isActive = true
        centerView.leftAnchor.constraint(equalTo: cardView.leftAnchor, constant: 0).isActive = true
        centerView.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: 0).isActive = true
        
        cardView.addSubview(bottomView)
        bottomViewTopConstraint.isActive = true
        bottomView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -4).isActive = true
        bottomView.leftAnchor.constraint(equalTo: cardView.leftAnchor, constant: 0).isActive = true
        bottomView.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: 0).isActive = true
    }
}
