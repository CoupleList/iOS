//
//  FeedbackViewController.swift
//  Couple List
//
//  Created by Kirin Patel on 7/5/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseAnalytics
import FirebaseDatabase

class FeedbackViewController: UIViewController {
    
    var ref: DatabaseReference!
    
    let emailContactLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Allow the developer (Kirin Patel) to contact you via your email address regarding your feedback?"
        label.numberOfLines = 0
        label.textColor = .white
        return label
    }()
    
    let emailContactSwitch: UISwitch = {
        let s = UISwitch()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.onTintColor = .white
        s.isOn = true
        return s
    }()
    
    let feedbackTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .white
        textView.textColor = .gray
        textView.text = "Feedback..."
        textView.font = UIFont.systemFont(ofSize: 15.0)
        textView.returnKeyType = .done
        textView.layer.cornerRadius = 12.0
        return textView
    }()
    
    let submitButton: CLPrimaryButton = {
        let button = CLPrimaryButton(title: "submit")
        button.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(named: "MainColor")
        title = "Submit Feedback"
        
        ref = Database.database().reference()
        
        setupView()
    }
    
    @objc func handleSubmit() {
        let key = ref.child("feedback/\(Auth.auth().currentUser!.uid)/").childByAutoId().key
        ref.child("feedback/\(Auth.auth().currentUser!.uid)/\(key)").setValue([
            "respondViaEmail": emailContactSwitch.isOn,
            "feedback": feedbackTextView.text
            ])
        
        let alert = UIAlertController(title: "Thanks for the feedback!", message: "Any suggestions are greatly appreciated and will be addressed prompty.", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {
            (_)in
           self.navigationController?.popViewController(animated: true)
        })
        
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    fileprivate func setupView() {
        view.addSubview(emailContactLabel)
        emailContactLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10.0).isActive = true
        emailContactLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8.0).isActive = true
        emailContactLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8.0).isActive = true
        
        view.addSubview(emailContactSwitch)
        emailContactSwitch.topAnchor.constraint(equalTo: emailContactLabel.bottomAnchor, constant: 4.0).isActive = true
        emailContactSwitch.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8.0).isActive = true
        
        view.addSubview(submitButton)
        submitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10.0).isActive = true
        submitButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 40.0).isActive = true
        submitButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -40.0).isActive = true
        submitButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        view.addSubview(feedbackTextView)
        feedbackTextView.topAnchor.constraint(equalTo: emailContactSwitch.bottomAnchor, constant: 10.0).isActive = true
        feedbackTextView.bottomAnchor.constraint(equalTo: submitButton.topAnchor, constant: -10.0).isActive = true
        feedbackTextView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8.0).isActive = true
        feedbackTextView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8.0).isActive = true
        feedbackTextView.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
}

extension FeedbackViewController: UITextViewDelegate {

    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView.text! == "Feedback...") {
            textView.text = ""
            textView.textColor = UIColor.init(named: "MainColor")
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (textView.text! == "") {
            textView.text = "Feedback..."
            textView.textColor = .gray
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.contains("\n") {
            textView.text = textView.text.replacingOccurrences(of: "\n", with: "")
            
            textView.resignFirstResponder()
        }
    }
}
