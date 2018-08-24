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
    
    let anonymousItem: CLSettingsSwitchInputItem = {
        let clSettingsSwitchInputItem = CLSettingsSwitchInputItem()
        clSettingsSwitchInputItem.iconImage = UIImage.init(named: "FeedbackAnonymous")
        clSettingsSwitchInputItem.title = "Remain Anonymous?"
        clSettingsSwitchInputItem.details = "Send feedback without email address"
        clSettingsSwitchInputItem.isOn = true
        return clSettingsSwitchInputItem
    }()
    
    let feedbackTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .white
        textView.textColor = .gray
        textView.text = "Feedback..."
        textView.font = UIFont.systemFont(ofSize: 15.0)
        textView.returnKeyType = .done
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
        if feedbackTextView.text.count > 0 && feedbackTextView.text != "Feedback..." {
            let key = ref.child("feedback/\(Auth.auth().currentUser!.uid)/").childByAutoId().key
            ref.child("feedback/\(Auth.auth().currentUser!.uid)/\(key)").setValue([
                "respondViaEmail": !anonymousItem.isOn,
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
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    fileprivate func setupView() {
        let settingsSubViews: [UIView] = [
            anonymousItem,
            CLSettingsItemSpacer(),
            feedbackTextView,
            CLSettingsItemSpacer(),
            submitButton,
            CLSettingsItemSpacer()
        ]
        
        let settingsStackView = UIStackView(arrangedSubviews: settingsSubViews)
        settingsStackView.translatesAutoresizingMaskIntoConstraints = false
        settingsStackView.axis = .vertical
        settingsStackView.alignment = .fill
        settingsStackView.distribution = .fill
        settingsStackView.spacing = 0
        
        view.addSubview(settingsStackView)
        settingsStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        settingsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        settingsStackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        settingsStackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        
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
