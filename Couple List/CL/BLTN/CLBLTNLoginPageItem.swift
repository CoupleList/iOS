//
//  CLBLTNLoginPageItem.swift
//  Couple List
//
//  Created by Kirin Patel on 1/2/19.
//  Copyright © 2019 Kirin Patel. All rights reserved.
//

import UIKit
import Ambience
import BLTNBoard

class CLBTNLoginPageItem: CLBLTNPageItem {
    
    public var emailAddressTextField: UITextField!
    
    public var passwordTextField: UITextField!
    
    private var emailAddress: String!
    
    override init() {
        super.init(title: "Login")
        setup()
    }
    
    init(emailAddress: String) {
        super.init(title: "Login")
        setup()
        self.emailAddress = emailAddress
    }
    
    override func makeViewsUnderTitle(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        emailAddressTextField = interfaceBuilder.makeTextField(placeholder: "Email Address",
                                                               returnKey: .next,
                                                               delegate: self)
        emailAddressTextField.keyboardType = .emailAddress
        emailAddressTextField.textContentType = .emailAddress
        emailAddressTextField.text = emailAddress
        passwordTextField = interfaceBuilder.makeTextField(placeholder: "Password",
                                                           returnKey: .done,
                                                           delegate: self)
        passwordTextField.textContentType = .password
        passwordTextField.isSecureTextEntry = true
        if Ambience.currentState == .invert {
            let attributes = [NSAttributedString.Key.foregroundColor : UIColor.lightGray]
            let emailAttributedPlaceholder = NSAttributedString(string: "Email Address",
                                                                attributes: attributes)
            let passwordAttributedPlaceholder = NSAttributedString(string: "Password",
                                                                   attributes: attributes)
            emailAddressTextField.backgroundColor = .black
            emailAddressTextField.textColor = .white
            emailAddressTextField.attributedPlaceholder = emailAttributedPlaceholder
            emailAddressTextField.layer.borderColor = UIColor.white.cgColor
            emailAddressTextField.layer.borderWidth = 1
            emailAddressTextField.layer.cornerRadius = 6
            passwordTextField.backgroundColor = .black
            passwordTextField.textColor = .white
            passwordTextField.attributedPlaceholder = passwordAttributedPlaceholder
            passwordTextField.layer.borderColor = UIColor.white.cgColor
            passwordTextField.layer.borderWidth = 1
            passwordTextField.layer.cornerRadius = 6
        }
        return [emailAddressTextField, passwordTextField]
    }
    
    override func tearDown() {
        super.tearDown()
        emailAddressTextField.delegate = nil
        passwordTextField.delegate = nil
    }
    
    override func actionButtonTapped(sender: UIButton) {
        if emailAddressTextField.isFirstResponder {
            emailAddressTextField.resignFirstResponder()
        }
        if passwordTextField.isFirstResponder {
            passwordTextField.resignFirstResponder()
        }
        super.actionButtonTapped(sender: sender)
    }
    
    fileprivate func setup() {
        actionButtonTitle = "Login"
        alternativeButtonTitle = "Back"
        alternativeHandler = { (item: BLTNActionItem) in
            if let manager = item.manager {
                manager.popToRootItem()
            }
        }
    }
}

extension CLBTNLoginPageItem: UITextFieldDelegate {
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if emailAddressTextField.isFirstResponder {
            emailAddressTextField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
            return false
        } else if passwordTextField.isFirstResponder {
            passwordTextField.resignFirstResponder()
        }
        return true
    }
}
