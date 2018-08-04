//
//  StartViewController.swift
//  Couple List
//
//  Created by Kirin Patel on 6/16/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import FirebaseAuth
import FirebaseDatabase

class StartViewController: CLBasicViewController {
    
    let emailAddressTextField: CLTextField = {
        let textField = CLTextField(placeHolder: "Email Address")
        textField.returnKeyType = .next
        textField.keyboardType = .emailAddress
        return textField
    }()
    
    let passwordTextField: CLTextField = {
        let textField = CLTextField(placeHolder: "Password")
        textField.isSecureTextEntry = true
        textField.returnKeyType = .done
        return textField
    }()
    
    let registerButton: CLSecondaryButton = {
        let button = CLSecondaryButton(title: "Register")
        button.alpha = 0
        button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        return button
    }()
    
    var handler: AuthStateDidChangeListenerHandle!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        handler = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.ref.child("users/\(user.uid)").observeSingleEvent(of: .value, with: { (snapshot) in
                    let view = MainViewController()
                    view.modalTransitionStyle = .crossDissolve
                    self.present(view, animated: true, completion: nil)
                })
            } else {
                self.animateView()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Auth.auth().removeStateDidChangeListener(handler!)
    }
    
    @objc func handleLogin() {
        Analytics.logEvent("handle_login", parameters: [:])
        
        let email = emailAddressTextField.text!
        let password = passwordTextField.text!
        
        if email.count == 0 || password.count == 0 {
            Analytics.logEvent("error_handling_login", parameters: [
                "error": "Blank Email Address or Password"
                ])
            
            let alert = UIAlertController(title: "Missing information", message: "An email address and password are required to sign in!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        } else if !email.contains("@") && !email.contains(".") {
            Analytics.logEvent("error_handling_login", parameters: [
                "error": "Incorrect Email Address"
                ])
            
            let alert = UIAlertController(title: "Missing information", message: "A valid email address is required to sign in!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (_, error) in
            if let error = error {
                Analytics.logEvent("error_handling_login", parameters: [
                    "error": error.localizedDescription
                    ])
                
                let alert = UIAlertController(title: "Error", message: "Unable to login.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.emailAddressTextField.text = ""
                self.passwordTextField.text = ""
            }
        })
    }
    
    @objc func handleRegister() {
        Analytics.logEvent("handle_register", parameters: [:])
        present(RegisterViewController(), animated: true, completion: nil)
    }
    
    @objc func handleForgotPassword() {
        Analytics.logEvent("handle_forgot_password", parameters: [:])
        
        let alert = UIAlertController(title: "Forgot Password", message: "Please enter your email address so that a password reset link can be sent.", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Email Address"
            textField.keyboardType = .emailAddress
        }
        
        let sendAction = UIAlertAction(title: "Send", style: .default) { _ in
            if let email = alert.textFields![0].text {
                if email.count == 0 {
                    Analytics.logEvent("error_handling_forgot_password", parameters: [
                        "error": "Blank Email Address"
                        ])
                    
                    let alert = UIAlertController(title: "Missing information", message: "An email address is required!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                } else if !email.contains("@") && !email.contains(".") {
                    Analytics.logEvent("error_handling_forgot_password", parameters: [
                        "error": "Incorrect Email Address"
                        ])
                    
                    let alert = UIAlertController(title: "Missing information", message: "A valid email address is required to sign in!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                Auth.auth().sendPasswordReset(withEmail: email, completion: { (error) in
                    if let error = error {
                        Analytics.logEvent("error_handling_forgot_password", parameters: [
                            "error": error.localizedDescription
                            ])
                        
                        let alert = UIAlertController(title: "Error", message: "Unable to send password reset email.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                })
            } else {
                Analytics.logEvent("error_handling_forgot_password", parameters: [
                    "error": "Unknown"
                    ])
                
                let alert = UIAlertController(title: "Missing information", message: "An email address is required!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            Analytics.logEvent("dismiss_handle_forgot_password", parameters: [:])
        }
        
        alert.addAction(sendAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func setupView() {
        titleLabel.text = "Couple List"
        titleLabel.alpha = 0
        
        descriptionLabel.text = "A simple, all in one place to keep track of what you and your S.O. do."
        descriptionLabel.alpha = 0
        
        centerStack.alpha = 0
        
        centerStack.addArrangedSubview(emailAddressTextField)
        emailAddressTextField.heightAnchor.constraint(equalToConstant: 35).isActive = true
        emailAddressTextField.delegate = self
        
        centerStack.addArrangedSubview(passwordTextField)
        passwordTextField.heightAnchor.constraint(equalToConstant: 35).isActive = true
        passwordTextField.delegate = self
        
        actionButton.setTitle("Login", for: .normal)
        actionButton.alpha = 0
        actionButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        
        bottomButton.setTitle("Forgot Password", for: .normal)
        bottomButton.alpha = 0
        bottomButton.addTarget(self, action: #selector(handleForgotPassword), for: .touchUpInside)
        
        view.addSubview(registerButton)
        registerButton.bottomAnchor.constraint(equalTo: bottomButton.topAnchor, constant: -10).isActive = true
        registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    fileprivate func animateView() {
        if titleLabel.alpha == 0 {
            titleLabel.transform = CGAffineTransform(translationX: 0, y: 20)
            descriptionLabel.transform = CGAffineTransform(translationX: 0, y: 20)
            
            UIView.animate(withDuration: 1, animations: { () in
                self.titleLabel.transform = CGAffineTransform(translationX: 0, y: 0)
                self.titleLabel.alpha = 1
            }, completion: { _ in
                UIView.animate(withDuration: 0.5, animations: { () in
                    self.descriptionLabel.transform = CGAffineTransform(translationX: 0, y: 0)
                    self.descriptionLabel.alpha = 1
                }, completion: { _ in
                    UIView.animate(withDuration: 0.5, animations: { () in
                        self.centerStack.alpha = 1
                        self.actionButton.alpha = 1
                        self.registerButton.alpha = 1
                        self.bottomButton.alpha = 1
                    })
                })
            })
        }
    }
}

extension StartViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if !textField.isSecureTextEntry {
            passwordTextField.becomeFirstResponder()
            
            return false
        }
        
        return true
    }
}
