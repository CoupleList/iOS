//
//  CLBLTNEditActivityPageItem.swift
//  Couple List
//
//  Created by Kirin Patel on 2/6/19.
//  Copyright © 2019 Kirin Patel. All rights reserved.
//

import UIKit
import Ambience
import BLTNBoard

class CLBLTNEditActivityPageItem: CLBLTNPageItem {

    public var titleField: UITextField!
    
    public var detailsField: UITextField!
    
    private var activity: CLActivity!
    
    init(activity: CLActivity) {
        super.init(title: "Edit Activity")
        setup()
        self.activity = activity
    }
    
    override func makeViewsUnderTitle(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        titleField = interfaceBuilder.makeTextField(placeholder: "Activity Title",
                                                    returnKey: .next,
                                                    delegate: self)
        titleField.text = activity.title
        detailsField = interfaceBuilder.makeTextField(placeholder: "Activity Details",
                                                      returnKey: .done,
                                                      delegate: self)
        detailsField.text = activity.desc
        if Ambience.currentState == .invert {
            let attributes = [NSAttributedString.Key.foregroundColor : UIColor.lightGray]
            let titleAttributedPlaceholder = NSAttributedString(string: "Activity Title",
                                                                attributes: attributes)
            let detailsAttributedPlaceholder = NSAttributedString(string: "Activity Details",
                                                                  attributes: attributes)
            titleField.backgroundColor = .black
            titleField.textColor = .white
            titleField.attributedPlaceholder = titleAttributedPlaceholder
            titleField.layer.borderColor = UIColor.white.cgColor
            titleField.layer.borderWidth = 1
            titleField.layer.cornerRadius = 6
            detailsField.backgroundColor = .black
            detailsField.textColor = .white
            detailsField.attributedPlaceholder = detailsAttributedPlaceholder
            detailsField.layer.borderColor = UIColor.white.cgColor
            detailsField.layer.borderWidth = 1
            detailsField.layer.cornerRadius = 6
        }
        return [titleField, detailsField]
    }
    
    override func tearDown() {
        super.tearDown()
        titleField.delegate = nil
        detailsField.delegate = nil
    }
    
    override func actionButtonTapped(sender: UIButton) {
        if titleField.isFirstResponder {
            titleField.resignFirstResponder()
        }
        if detailsField.isFirstResponder {
            detailsField.resignFirstResponder()
        }
        super.actionButtonTapped(sender: sender)
    }
    
    fileprivate func setup() {
        actionButtonTitle = "Save"
        alternativeButtonTitle = "Cancel"
        isDismissable = true
        requiresCloseButton = true
        alternativeHandler = { (item: BLTNActionItem) in
            if let manager = item.manager {
                manager.dismissBulletin()
            }
        }
    }
}

extension CLBLTNEditActivityPageItem: UITextFieldDelegate {
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if titleField.isFirstResponder {
            titleField.resignFirstResponder()
            detailsField.becomeFirstResponder()
            return false
        } else if detailsField.isFirstResponder {
            detailsField.resignFirstResponder()
        }
        return true
    }
}
