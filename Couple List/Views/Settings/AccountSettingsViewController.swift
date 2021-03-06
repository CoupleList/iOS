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

class AccountSettingsViewController: UIViewController {
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.indicatorStyle = .black
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
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
    
    let displayNameLabel = CLTitleLabel(text: CL.shared.displayName())
    
    let setProfileImageItem: CLSettingsItem = {
        let clSettingsItem = CLSettingsItem()
        clSettingsItem.iconImage = UIImage.init(named: "profilePicture")
        clSettingsItem.title = "Set Profile Picture"
        clSettingsItem.details = "Select a picture to be used"
        return clSettingsItem
    }()
    
    let setDisplayNameItem: CLSettingsItem = {
        let clSettingsItem = CLSettingsItem()
        clSettingsItem.iconImage = UIImage.init(named: "rename")
        clSettingsItem.title = "Set Display Name"
        clSettingsItem.details = "Set a display name to be used"
        return clSettingsItem
    }()
    
    let changePasswordItem: CLSettingsItem = {
        let clSettingsItem = CLSettingsItem()
        clSettingsItem.iconImage = UIImage.init(named: "changePassword")
        clSettingsItem.title = "Change Password"
        clSettingsItem.details = "Change your password"
        return clSettingsItem
    }()
    
    let accountDataIem: CLSettingsItem = {
        let clSettingsItem = CLSettingsItem()
        clSettingsItem.iconImage = UIImage.init(named: "data")
        clSettingsItem.title = "View Account Data"
        clSettingsItem.details = "View all your account data"
        return clSettingsItem
        
    }()
    
    var ref: DatabaseReference!
    var storage: Storage!
    var profileImage: UIImage? {
        didSet {
            profileImageActivityIndicator.stopAnimating()
            profileImageView.image = profileImage
        }
    }
    var displayName: String? {
        didSet {
            if let displayName = displayName {
                displayNameLabel.text = displayName.isEmpty ? "" : displayName
            }
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
    
    @objc func handleSetProfileImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let alert = UIAlertController(title: "Set Profile Picture", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Take a Photo", style: .default) {
            _ in
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true)
        })
        alert.addAction(UIAlertAction(title: "Choose from Camera Roll", style: .default) {
            _ in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc func handlePasswordChange() {
        displayChangePasswordAlert()
    }
    
    @objc func handleViewAccountData() {
        let alert = UIAlertController(title: "View Account Data?", message: "Please be aware that there may be sensitive information presented. Please ensure that you are in a secure location to prevent this information from being visible to others.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "View", style: .default) { _ in
            self.navigationController?.pushViewController(AccountDataViewController(), animated: true)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc func handleDeleteAccount() {
        let alert = UIAlertController(title: "Are you sure you want to delete your account?", message: "Deleting your account will delete all data associated with your account.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {
            _ in
            let confirmAlert = UIAlertController(title: "Are you sure you want to permanently delete this account?", message: "", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                // TODO: Add code to actually delete account
            })
            
            confirmAlert.addAction(cancelAction)
            confirmAlert.addAction(deleteAction)
            
            self.present(confirmAlert, animated: true)
        })
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        present(alert, animated: true)
    }
    
    @objc func setDisplayName() {
        let alert = UIAlertController(title: "Set Display Name", message: "", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Display Name"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            if let displayName = alert.textFields![0].text {
                self.displayName = displayName
                self.ref.child("users/\(Auth.auth().currentUser!.uid)/displayName").setValue(!displayName.isEmpty ? displayName : nil)
            } else {
                // TODO: add error alert
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    fileprivate func setupView() {
        view.addSubview(scrollView)
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        scrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        
        setProfileImageItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSetProfileImage)))
        setDisplayNameItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(setDisplayName)))
        changePasswordItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePasswordChange)))
        accountDataIem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleViewAccountData)))
        
        let provileImageViewContainer: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        provileImageViewContainer.addSubview(profileImageView)
        profileImageView.topAnchor.constraint(equalTo: provileImageViewContainer.topAnchor, constant: 0).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: provileImageViewContainer.bottomAnchor, constant: 0).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: provileImageViewContainer.centerXAnchor).isActive = true
        
        let settingsSubViews: [UIView] = [
            CLSettingsItemSpacer(),
            provileImageViewContainer,
            CLSettingsItemSpacer(),
            displayNameLabel,
            CLSettingsItemSpacer(),
            setProfileImageItem,
            setDisplayNameItem,
            CLSettingsItemSpacer(),
            changePasswordItem,
            CLSettingsItemSpacer(),
            accountDataIem
        ]
        
        let settingsStackView = UIStackView(arrangedSubviews: settingsSubViews)
        settingsStackView.translatesAutoresizingMaskIntoConstraints = false
        settingsStackView.axis = .vertical
        settingsStackView.alignment = .fill
        settingsStackView.distribution = .fill
        settingsStackView.spacing = 0
        
        scrollView.addSubview(settingsStackView)
        settingsStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0).isActive = true
        settingsStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0).isActive = true
        settingsStackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        settingsStackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        
        scrollView.bounds = view.bounds
        scrollView.contentSize = CGSize(width: view.bounds.width, height: .infinity)
    }
    
    fileprivate func loadProfileImage() {
        profileImage = CL.shared.profileImages[Auth.auth().currentUser!.uid]
        profileImageActivityIndicator.startAnimating()
        let profileImageRef = storage.reference(withPath:"profileImages/\(Auth.auth().currentUser!.uid).JPG")
        
        profileImageRef.getData(maxSize: 8 * 1024 * 1024) { data, error in
            if error != nil {
                self.profileImageActivityIndicator.stopAnimating()
            } else {
                self.profileImage = UIImage(data: data!)
            }
        }
    }
    
    fileprivate func uploadProfileImage(image: UIImage) {
        let alert = UIAlertController(title: "Uploading Profile Picture", message: "Please wait while your profile picture is uploading...", preferredStyle: .alert)
        present(alert, animated: true)
        profileImageActivityIndicator.startAnimating()
        
        if let data = UIImageJPEGRepresentation(image, 0.3) {
            let uid = Auth.auth().currentUser!.uid
            let profileImageRef = storage.reference(withPath: "profileImages/\(uid)_original_\(image.imageOrientation.rawValue).JPG")
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            let uploadTask = profileImageRef.putData(data, metadata: metaData)
            
            uploadTask.observe(.success) { snapshot in
                uploadTask.removeAllObservers()
                alert.dismiss(animated: true)
                self.profileImage = image
                
                let alert = UIAlertController(title: "Profile Picture Updated", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
                
                CL.shared.profileImages.updateValue(image, forKey: uid)
            }
            
            uploadTask.observe(.failure) { snapshot in
                uploadTask.removeAllObservers()
                if let error = snapshot.error as NSError? {
                    let alert = UIAlertController(title: "Error Updating Profile Picture", message: "\(error.localizedDescription) Would you like to retry?", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
                        self.uploadProfileImage(image: image)
                    }))
                    self.present(alert, animated: true)
                } else {
                    let alert = UIAlertController(title: "Error Updating Profile Picture", message: "There was an unknown error that occurred while uploading your profile picture. Would you like to retry?", preferredStyle: .alert)
                    alert.addAction( UIAlertAction(title: "Cancel", style: .cancel))
                    alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
                        self.uploadProfileImage(image: image)
                    }))
                    self.present(alert, animated: true)
                }
            }
        } else {
            
        }
    }
    
    fileprivate func loadDisplayName() {
        ref.child("users/\(Auth.auth().currentUser!.uid)/displayName").observeSingleEvent(of: .value, with: { snapshot in
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
        
        let okAction = UIAlertAction(title: "Change Password", style: .default) { _ in
            let password: String = alert.textFields![0].text!
            let verifyPassword: String = alert.textFields![1].text!
            
            if password.isEmpty || verifyPassword.isEmpty  {
                let errorAlert = UIAlertController(title: "Error Changing Password", message: "A new password must be provided.", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.displayChangePasswordAlert()
                })
                
                errorAlert.addAction(okAction)
                
                self.present(errorAlert, animated: true)
                return
            } else if password != verifyPassword {
                let errorAlert = UIAlertController(title: "Error Changing Password", message: "The provided passwords do not match.", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.displayChangePasswordAlert()
                })
                
                errorAlert.addAction(okAction)
                
                self.present(errorAlert, animated: true)
                return
            }
            
            Auth.auth().currentUser!.updatePassword(to: password, completion: {
                (error) in
                if error != nil {
                    let errorAlert = UIAlertController(title: "Error Changing Password", message: error!.localizedDescription, preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        self.displayChangePasswordAlert()
                    }))
                    self.present(errorAlert, animated: true)
                    return
                }
                
                let successAlert = UIAlertController(title: "Password Updated", message: "Your account password has been successfully updated.", preferredStyle: .alert)
                successAlert.addAction(UIAlertAction(title: "OK", style: .default))
                
                self.present(successAlert, animated: true)
            })
        }
        alert.addAction(okAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
}

extension AccountSettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true)
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            uploadProfileImage(image: selectedImage)
        }
    }
}
