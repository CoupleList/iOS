//
//  CLBLTNRegisterPageItem.swift
//  Couple List
//
//  Created by Kirin Patel on 1/2/19.
//  Copyright © 2019 Kirin Patel. All rights reserved.
//

import UIKit
import BLTNBoard

class CLBLTNRegisterPageItem: CLBLTNPageItem {
    
    @objc public var emailAddressTextField: UITextField!
    
    @objc public var passwordTextField: UITextField!
    
    @objc public var confirmPasswordTextField: UITextField!
    
    override init() {
        super.init(title: "Register")
        setup()
    }
    
    init(emailAddress: String) {
        super.init(title: "Register")
        setup()
    }
    
    override func makeViewsUnderTitle(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        emailAddressTextField = interfaceBuilder.makeTextField(placeholder: "Email Address",
                                                               returnKey: .next,
                                                               delegate: self)
        emailAddressTextField.keyboardType = .emailAddress
        emailAddressTextField.textContentType = .emailAddress
        passwordTextField = interfaceBuilder.makeTextField(placeholder: "Password",
                                                           returnKey: .next,
                                                           delegate: self)
        if #available(iOS 12.0, *) {
            passwordTextField.textContentType = .newPassword
        } else {
            passwordTextField.textContentType = .password
        }
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField = interfaceBuilder.makeTextField(placeholder: "Confirm Password",
                                                           returnKey: .done,
                                                           delegate: self)
        if #available(iOS 12.0, *) {
            confirmPasswordTextField.textContentType = .newPassword
        } else {
            confirmPasswordTextField.textContentType = .password
        }
        confirmPasswordTextField.isSecureTextEntry = true
        return [emailAddressTextField,
                passwordTextField,
                confirmPasswordTextField]
    }
    
    override func tearDown() {
        super.tearDown()
        emailAddressTextField.delegate = nil
        passwordTextField.delegate = nil
        confirmPasswordTextField.delegate = nil
    }
    
    override func actionButtonTapped(sender: UIButton) {
        if emailAddressTextField.isFirstResponder {
            emailAddressTextField.resignFirstResponder()
        }
        if passwordTextField.isFirstResponder {
            passwordTextField.resignFirstResponder()
            confirmPasswordTextField.becomeFirstResponder()
        }
        if confirmPasswordTextField.isFirstResponder {
            confirmPasswordTextField.resignFirstResponder()
        }
        super.actionButtonTapped(sender: sender)
    }
    
    fileprivate func setup() {
        actionButtonTitle = "Register"
        alternativeButtonTitle = "Back"
        alternativeHandler = { (item: BLTNActionItem) in
            if let manager = item.manager {
                manager.popToRootItem()
            }
        }
    }
}

extension CLBLTNRegisterPageItem: UITextFieldDelegate {
    
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
            confirmPasswordTextField.becomeFirstResponder()
            return false
        } else if confirmPasswordTextField.isFirstResponder {
            confirmPasswordTextField.resignFirstResponder()
        }
        return true
    }
}
