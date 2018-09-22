//
//  RegisterViewController.swift
//  Couple List
//
//  Created by Kirin Patel on 6/17/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import FirebaseAuth
import FirebaseDatabase

class RegisterViewController: CLBasicViewController {
    
    let displayNameTextField: CLTextField = {
        let textField = CLTextField(placeHolder: "Display Name")
        textField.returnKeyType = .next
        return textField
    }()
    
    let emailAddressTextField: CLTextField = {
        let textField = CLTextField(placeHolder: "Email Address")
        textField.returnKeyType = .next
        textField.keyboardType = .emailAddress
        return textField
    }()
    
    let passwordTextField: CLTextField = {
        let textField = CLTextField(placeHolder: "Password")
        textField.isSecureTextEntry = true
        textField.returnKeyType = .next
        return textField
    }()
    
    let confirmPasswordTextField: CLTextField = {
        let textField = CLTextField(placeHolder: "Confirm Password")
        textField.isSecureTextEntry = true
        textField.returnKeyType = .done
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    @objc func handleBack() {
        Analytics.logEvent("handle_back", parameters: [:])
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleRegister() {
        Analytics.logEvent("handle_register", parameters: [:])
        
        let displayName = displayNameTextField.text!
        let email = emailAddressTextField.text!
        let password = passwordTextField.text!
        let confirmPassword = confirmPasswordTextField.text!
        
        if displayName.count == 0 || email.count == 0 || password.count == 0 || confirmPassword.count == 0 {
            Analytics.logEvent("error_handling_register", parameters: [
                "error": "Blank Display Name, Email Address, Password or Confirm Password"
                ])
            
            let alert = UIAlertController(title: "Missing Information", message: "A display name, email address, password, and password confirmation are required to register.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
            return
        } else if !email.contains("@") && !email.contains(".") {
            Analytics.logEvent("error_handling_register", parameters: [
                "error": "Incorrect Email Address"
                ])
            
            let alert = UIAlertController(title: "Missing information", message: "A valid email address is required to sign in.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
            return
        } else if password != confirmPassword {
            Analytics.logEvent("error_handling_register", parameters: [
                "error": "Mismatching passwords"
                ])
            
            let alert = UIAlertController(title: "Incorrect information", message: "The provided passwords do not match.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (auth, error) in
            if let error = error {
                Analytics.logEvent("error_handling_register", parameters: [
                    "error": error.localizedDescription
                    ])
                
                let alert = UIAlertController(title: "Error", message: "Unable to complete registration.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            } else {
                if let user = auth?.user {
                    Database.database().reference().child("users/\(user.uid)/displayName").setValue(displayName)
                }
                
                Analytics.logEvent("handled_register", parameters: [:])
                self.dismiss(animated: true)
            }
        })
    }
    
    fileprivate func setupView() {
        titleLabel.text = "Register"
        
        descriptionLabel.text = "Create an account to get started."
        
        centerStack.addArrangedSubview(displayNameTextField)
        displayNameTextField.heightAnchor.constraint(equalToConstant: 35).isActive = true
        displayNameTextField.delegate = self
        
        centerStack.addArrangedSubview(emailAddressTextField)
        emailAddressTextField.heightAnchor.constraint(equalToConstant: 35).isActive = true
        emailAddressTextField.delegate = self
        
        centerStack.addArrangedSubview(passwordTextField)
        passwordTextField.heightAnchor.constraint(equalToConstant: 35).isActive = true
        passwordTextField.delegate = self
        
        centerStack.addArrangedSubview(confirmPasswordTextField)
        confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 35).isActive = true
        confirmPasswordTextField.delegate = self
        
        actionButton.setTitle("Register", for: .normal)
        actionButton.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        
        bottomButton.setTitle("Back", for: .normal)
        bottomButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
    }
}

extension RegisterViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        if textField == displayNameTextField {
            emailAddressTextField.becomeFirstResponder()
            return false
        } else if textField == emailAddressTextField {
            passwordTextField.becomeFirstResponder()
            return false
        } else if textField == passwordTextField {
            confirmPasswordTextField.becomeFirstResponder()
            return false
        }

        return true
    }
}
