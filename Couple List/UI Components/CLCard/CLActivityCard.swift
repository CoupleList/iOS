//
//  CLActivityCard.swift
//  Couple List
//
//  Created by Kirin Patel on 11/13/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit

class CLActivityCard: CLCard {
    
    fileprivate let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    fileprivate lazy var profileImageViewWidthConstraint = profileImageView.widthAnchor.constraint(equalToConstant: 0)
    fileprivate lazy var profileImageViewHeightConstraint = profileImageView.heightAnchor.constraint(equalToConstant: 40)
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.baselineAdjustment = .alignCenters
        label.minimumScaleFactor = 0.6
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        label.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return label
    }()
    
    fileprivate let completedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.init(named: "AppleGreen")
        label.text = " "
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        label.widthAnchor.constraint(equalToConstant: 10).isActive = true
        label.heightAnchor.constraint(equalToConstant: 10).isActive = true
        return label
    }()
    
    var activity: Activity! {
        didSet {
            let contentViews = createViewForActivity(activity)
            
            headerContent = contentViews[0]
            centerContent = contentViews[1]
            bottomContent = contentViews[2]
        }
    }
    
    override init() {
        super.init()
    }
    
    init(activity: Activity) {
        super.init()
        
        self.activity = activity
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func createViewForActivity(_ activity: Activity) -> [[UIView]] {
        var headerContent: [UIView] = [UIView]()
        var centerContent: [UIView] = [UIView]()
        var bottomContent: [UIView] = [UIView]()
        
        if let person = activity.person {
            setProfileImage(person)
            profileImageViewWidthConstraint.isActive = true
            profileImageViewHeightConstraint.isActive = true
            headerContent.append(profileImageView)
        }
        
        titleLabel.text = activity.title
        headerContent.append(titleLabel)
        
        return [headerContent, centerContent, bottomContent]
    }
    
    fileprivate func setProfileImage(_ person: String) {
        if CL.shared.profileImages.index(forKey: person) != nil {
            profileImageView.image = CL.shared.profileImages[person]!
            profileImageViewWidthConstraint.constant = 40
            profileImageView.setNeedsUpdateConstraints()
        } else {
            CL.shared.fetchProfileImage(uid: person) {
                self.profileImageView.image = CL.shared.profileImages[person]!
                self.profileImageViewWidthConstraint.constant = 40
                self.profileImageView.setNeedsUpdateConstraints()
            }
        }
    }
}
