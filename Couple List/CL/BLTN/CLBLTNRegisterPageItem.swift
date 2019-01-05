//
//  CLBLTNRegisterPageItem.swift
//  Couple List
//
//  Created by Kirin Patel on 1/2/19.
//  Copyright © 2019 Kirin Patel. All rights reserved.
//

import UIKit
import Ambience
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
        if Ambience.currentState == .invert {
            let attributes = [NSAttributedString.Key.foregroundColor : UIColor.lightGray]
            let emailAttributedPlaceholder = NSAttributedString(string: "Email Address",
                                                                attributes: attributes)
            let passwordAttributedPlaceholder = NSAttributedString(string: "Password",
                                                                   attributes: attributes)
            let confirmPasswordAttributedPlaceholder = NSAttributedString(string: "Confirm Password",
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
            confirmPasswordTextField.backgroundColor = .black
            confirmPasswordTextField.textColor = .white
            confirmPasswordTextField.attributedPlaceholder = confirmPasswordAttributedPlaceholder
            confirmPasswordTextField.layer.borderColor = UIColor.white.cgColor
            confirmPasswordTextField.layer.borderWidth = 1
            confirmPasswordTextField.layer.cornerRadius = 6
        }
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
