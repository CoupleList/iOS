//
//  CLBLTNLoginPageItem.swift
//  Couple List
//
//  Created by Kirin Patel on 1/2/19.
//  Copyright © 2019 Kirin Patel. All rights reserved.
//

import UIKit
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
