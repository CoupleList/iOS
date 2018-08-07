//
//  UserSettingsViewController.swift
//  Couple List
//
//  Created by Kirin Patel on 7/5/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import Photos
import FirebaseAuth
import FirebaseAnalytics
import FirebaseDatabase
import FirebaseStorage

class AccountSettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 75.0
        iv.layer.masksToBounds = true
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 1.25
        return iv
    }()
    
    let profileImageActivityIndicator: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView()
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    let addProfileImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 75.0
        button.addTarget(self, action: #selector(handleSetProfileImage), for: .touchUpInside)
        return button
    }()
    
    let setDisplayNameButton: CLSecondaryButton = {
        let button = CLSecondaryButton(title: "")
        button.addTarget(self, action: #selector(setDisplayName), for: .touchUpInside)
        return button
    }()
    
    let resetPasswordButton: CLPrimaryButton = {
        let button = CLPrimaryButton(title: "change password")
        button.setTitleColor(UIColor.init(named: "AppleBlue"), for: .normal)
        button.addTarget(self, action: #selector(handlePasswordChange), for: .touchUpInside)
        return button
    }()
    
    let accountDataButton: CLPrimaryButton = {
        let button = CLPrimaryButton(title: "account data")
        button.addTarget(self, action: #selector(handleViewAccountData), for: .touchUpInside)
        return button
    }()
    
    let deleteAccountButton: CLPrimaryButton = {
        let button = CLPrimaryButton(title: "delete account")
        button.setTitleColor(UIColor.init(named: "AppleRed"), for: .normal)
        button.addTarget(self, action: #selector(handleDeleteAccount), for: .touchUpInside)
        return button
    }()
    
    var ref: DatabaseReference!
    var storage: Storage!
    var profileImage: UIImage? {
        didSet {
            addProfileImageButton.setTitle("", for: .normal)
            profileImageActivityIndicator.stopAnimating()
            profileImageView.image = profileImage
        }
    }
    var displayName: String? {
        didSet {
            setDisplayNameButton.setTitle(displayName!.isEmpty ? "Set Display Name": displayName, for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(named: "MainColor")
        title = "Account Settings"
        
        ref = Database.database().reference()
        storage = Storage.storage()
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if profileImage == nil {
            loadProfileImage()
        }
        
        if displayName == nil {
            loadDisplayName()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if let localFile = info[UIImagePickerControllerImageURL] as? URL {
                uploadProfileImage(image: selectedImage, url: localFile)
            } else {
                
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleSetProfileImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let alert = UIAlertController(title: "Set Profile Picture", message: "Please take or choose a picture to use as your profile picture.", preferredStyle: .alert)
        
        let cameraAction = UIAlertAction(title: "Take a Picture", style: .default) {
            _ in
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        }
        let photoAction = UIAlertAction(title: "Choose a Picture", style: .default) {
            _ in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cameraAction)
        alert.addAction(photoAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func handlePasswordChange() {
        displayChangePasswordAlert()
    }
    
    @objc func handleViewAccountData() {
        navigationController?.pushViewController(AccountDataViewController(), animated: true)
    }
    
    @objc func handleDeleteAccount() {
        let alert = UIAlertController(title: "Are you sure you want to delete your account?", message: "Deleting your account will delete all data associated with your account. This is a destructive process and is not reversable.", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete Account", style: .destructive, handler: {
            _ in
            let confirmAlert = UIAlertController(title: "Permanently Delete Account", message: "Please ensure you want to delete your account as your decision is not reverable.", preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let deleteAction = UIAlertAction(title: "Permanently Delete Account", style: .destructive, handler: {
                _ in
            })
            
            confirmAlert.addAction(cancelAction)
            confirmAlert.addAction(deleteAction)
            
            self.present(confirmAlert, animated: true, completion: nil)
        })
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func setDisplayName() {
        let alert = UIAlertController(title: "Set Display Name", message: "", preferredStyle: .alert)
        
        alert.addTextField{ (textField) -> Void in
            textField.keyboardType = .default
            textField.placeholder = "Display Name"
        }
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: {
            _ in
            let displayName: String = alert.textFields![0].text!
            
            self.displayName = displayName
            self.ref.child("users/\(Auth.auth().currentUser!.uid)/displayName").setValue(displayName.count > 0 ? displayName : nil)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func setupView() {
        view.addSubview(profileImageView)
        profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40.0).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150.0).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150.0).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(addProfileImageButton)
        addProfileImageButton.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 0.0).isActive = true
        addProfileImageButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 0.0).isActive = true
        addProfileImageButton.leftAnchor.constraint(equalTo: profileImageView.leftAnchor, constant: 0.0).isActive = true
        addProfileImageButton.rightAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 0.0).isActive = true
        
        view.addSubview(profileImageActivityIndicator)
        profileImageActivityIndicator.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 0.0).isActive = true
        profileImageActivityIndicator.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 0.0).isActive = true
        profileImageActivityIndicator.leftAnchor.constraint(equalTo: profileImageView.leftAnchor, constant: 0.0).isActive = true
        profileImageActivityIndicator.rightAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 0.0).isActive = true
        
        view.addSubview(setDisplayNameButton)
        setDisplayNameButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10.0).isActive = true
        setDisplayNameButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0.0).isActive = true
        setDisplayNameButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0.0).isActive = true
        setDisplayNameButton.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        
        view.addSubview(resetPasswordButton)
        resetPasswordButton.topAnchor.constraint(equalTo: setDisplayNameButton.bottomAnchor, constant: 10.0).isActive = true
        resetPasswordButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 40.0).isActive = true
        resetPasswordButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -40.0).isActive = true
        resetPasswordButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        view.addSubview(deleteAccountButton)
        deleteAccountButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10.0).isActive = true
        deleteAccountButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 40.0).isActive = true
        deleteAccountButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -40.0).isActive = true
        deleteAccountButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
//        view.addSubview(accountDataButton)
//        accountDataButton.bottomAnchor.constraint(equalTo: deleteAccountButton.topAnchor, constant: -10.0).isActive = true
//        accountDataButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 40.0).isActive = true
//        accountDataButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -40.0).isActive = true
//        accountDataButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
    }
    
    fileprivate func loadProfileImage() {
        profileImageActivityIndicator.startAnimating()
        let profileImageRef = storage.reference(withPath:"profileImages/\(Auth.auth().currentUser!.uid).JPG")
        
        profileImageRef.getData(maxSize: 8 * 1024 * 1024) { data, error in
            if error != nil {
                self.profileImageActivityIndicator.stopAnimating()
                self.addProfileImageButton.setTitle("Set Profile Picture", for: .normal)
            } else {
                self.profileImage = UIImage(data: data!)
            }
        }
    }
    
    fileprivate func uploadProfileImage(image: UIImage, url: URL) {
        profileImageActivityIndicator.startAnimating()
        
        let uid = Auth.auth().currentUser!.uid
        let profileImageRef = storage.reference(withPath: "profileImages/\(uid)_original_\(image.imageOrientation.rawValue).JPG")
        let uploadTask = profileImageRef.putFile(from: url)
        
        uploadTask.observe(.success) { snapshot in
            uploadTask.removeAllObservers()
            self.profileImage = image
            
            let alert = UIAlertController(title: "Profile Picture Updated", message: "Your profile picture was uploaded and set!", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alert.addAction(okAction)
            
            self.present(alert, animated: true, completion: nil)
            
            ActivitiesTableViewController.profileImages.updateValue(image, forKey: uid)
        }
        
        uploadTask.observe(.failure) { snapshot in
            uploadTask.removeAllObservers()
            if let error = snapshot.error as? NSError {
                let alert = UIAlertController(title: "Error Updating Profile Picture", message: "\(error.localizedDescription) Would you like to retry?", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: {
                    _ in
                    self.uploadProfileImage(image: image, url: url)
                })
                
                alert.addAction(cancelAction)
                alert.addAction(retryAction)
                
                self.present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Error Updating Profile Picture}", message: "There was an unknown error that occurred while uploading your profile picture. Would you like to retry?", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: {
                    _ in
                    self.uploadProfileImage(image: image, url: url)
                })
                
                alert.addAction(cancelAction)
                alert.addAction(retryAction)
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    fileprivate func loadDisplayName() {
        ref.child("users/\(Auth.auth().currentUser!.uid)/displayName").observeSingleEvent(of: .value, with: {
            (snapshot) in
            
            self.displayName = snapshot.exists() ? snapshot.value as! String : ""
        })
    }
    
    fileprivate func displayChangePasswordAlert() {
        let alert = UIAlertController(title: "Change Password", message: "Please provide a new password to be used with your account.", preferredStyle: .alert)
        
        alert.addTextField { (textField) -> Void in
            textField.keyboardType = .default
            textField.isSecureTextEntry = true
            textField.placeholder = "Password"
        }
        alert.addTextField { (textField) -> Void in
            textField.keyboardType = .default
            textField.isSecureTextEntry = true
            textField.placeholder = "Verify Password"
        }
        
        let okAction = UIAlertAction(title: "Change Password", style: .default) {
            _ in
            let password: String = alert.textFields![0].text!
            let verifyPassword: String = alert.textFields![1].text!
            
            if password.isEmpty || verifyPassword.isEmpty  {
                let errorAlert = UIAlertController(title: "Error Changing Password", message: "A new password must be provided!", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: {
                    _ in
                    self.displayChangePasswordAlert()
                })
                
                errorAlert.addAction(okAction)
                
                self.present(errorAlert, animated: true, completion: nil)
                return
            } else if password != verifyPassword {
                let errorAlert = UIAlertController(title: "Error Changing Password", message: "The provided passwords must match!", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: {
                    _ in
                    self.displayChangePasswordAlert()
                })
                
                errorAlert.addAction(okAction)
                
                self.present(errorAlert, animated: true, completion: nil)
                return
            }
            
            Auth.auth().currentUser!.updatePassword(to: password, completion: {
                (error) in
                if error != nil {
                    let errorAlert = UIAlertController(title: "Error Changing Password", message: error!.localizedDescription, preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: {
                        _ in
                        self.displayChangePasswordAlert()
                    })
                    
                    errorAlert.addAction(okAction)
                    
                    self.present(errorAlert, animated: true, completion: nil)
                    return
                }
                
                let successAlert = UIAlertController(title: "Password Updated", message: "Your account password has been successfully updated!", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                
                successAlert.addAction(okAction)
                
                self.present(successAlert, animated: true, completion: nil)
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}
