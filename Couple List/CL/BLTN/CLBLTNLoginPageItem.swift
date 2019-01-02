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
    
    @objc public var emailAddressTextField: UITextField!
    
    @objc public var passwordTextField: UITextField!
    
    override init() {
        super.init(title: "Login")
        setup()
    }
    
    override func makeViewsUnderTitle(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        emailAddressTextField = interfaceBuilder.makeTextField(placeholder: "Email Address",
                                                               returnKey: .next,
                                                               delegate: self)
        emailAddressTextField.keyboardType = .emailAddress
        emailAddressTextField.textContentType = .emailAddress
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
        descriptionText = ""
        actionButtonTitle = "Login"
        alternativeButtonTitle = "Back"
        alternativeHandler = { (item: BLTNActionItem) in
            if let manager = item.manager {
                manager.popItem()
            }
        }
    }
}

extension CLBTNLoginPageItem: UITextFieldDelegate {
    
    fileprivate func isEmailValid(email: String) -> Bool {
        return !email.isEmpty && email.contains("@") == true && email.contains(".") == true
    }
    
    fileprivate func isInputValid(text: String) -> Bool {
        return !text.isEmpty
    }
    
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        descriptionLabel!.text = ""
        emailAddressTextField.backgroundColor = .white
        passwordTextField.backgroundColor = .white
        if !isEmailValid(email: emailAddressTextField.text ?? "") {
            descriptionLabel!.text = "A valid email address is required."
            descriptionLabel!.textColor = .red
            emailAddressTextField.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        }
        if !isInputValid(text: passwordTextField.text ?? "") {
            if !descriptionLabel!.text!.isEmpty {
                descriptionLabel!.text = "\(descriptionLabel!.text)\nA password is required."
            } else {
                descriptionLabel!.text = "A password is required."
            }
            descriptionLabel!.textColor = .red
            passwordTextField.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        }
    }
}
