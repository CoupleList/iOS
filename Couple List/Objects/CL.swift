//
//  CL.swift
//  Couple List
//
//  Created by Kirin Patel on 8/24/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import FirebaseStorage

class CL {
    
    static let shared = CL()
    
    var userSettings: UserSettings = UserSettings.init(listKey: "", listCode: "")!
    var profileDisplayNames = [String:String]()
    var profileImages = [String:UIImage]()
    
    /**
        Any existing fetches for profile images from FirebaseStorage.
     
        This array will only hold the uid of users while their profile image is
        being fetched. Only one instance of a uid will exist at a time.
    */
    fileprivate var occuringProfileImageFetchs = [String]()
    
    /**
        Any additional fetches for profile images from FirebaseStorage that are
        made while the uid of a user is within occuringProfileImageFetchs are
        stored within this variable for later usage.
     
        This hash holds the uid of a user that has already had a fetch for their
        profile image be exectued and a completion handler which allows an
        existing fetch to call upon it once the fetch is completed.
    */
    fileprivate var awaitingProfileImageFetches = [String:[() -> Void]]()
    
    func setNoAds(noAds: Bool) {
        UserDefaults.standard.set(noAds, forKey: "noAds")
    }
    
    func noAds() -> Bool {
        return UserDefaults.standard.bool(forKey: "noAds")
    }
    
    func setDisplayName(displayName: String) {
        UserDefaults.standard.set(displayName, forKey: "displayName")
    }
    
    func displayName() -> String {
        return UserDefaults.standard.string(forKey: "displayName") ?? ""
    }
    
    class func generateDirectionsAlert(placemark: CLPlacemark, completion: @escaping (_ alert: UIAlertController) -> Void) {
        let alert = UIAlertController(title: "Get directions to \(placemark.name ?? "to activity")?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            if let addressDictionary = placemark.addressDictionary as! [String:AnyObject]?, let coordinate = placemark.location?.coordinate {
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary))
                let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                mapItem.openInMaps(launchOptions: launchOptions)
            }
        }))
        completion(alert)
    }
    
    fileprivate func updateFetchProfileImageCompletionHandlers(person: String) {
        if awaitingProfileImageFetches[person] != nil {
            while let last = awaitingProfileImageFetches[person]?.popLast() {
                last()
            }
        }
    }
    
    /**
        Fetches a requested profile image for a provided uid.
     
        - Parameters:
            - uid: The uid of the user whos profile image is being requested
            - completion: Completion handler that is called upon once the
                          FIRStorageReference getData() function completion
                          handler is called.
    */
    func fetchProfileImage(uid: String, completion: @escaping () -> Void) {
        if !occuringProfileImageFetchs.contains(uid) {
            occuringProfileImageFetchs.append(uid)
            let profileImageRef = Storage.storage().reference(withPath: "profileImages/\(uid).JPG")
            profileImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                
                if error == nil {
                    if let index = self.occuringProfileImageFetchs.firstIndex(of: uid) {
                        self.occuringProfileImageFetchs.remove(at: index)
                    }
                    CL.shared.profileImages.updateValue(UIImage(data: data!)!, forKey: uid)
                } else {
                    CL.shared.profileImages.updateValue(UIImage.init(named: "profilePicture")!, forKey: uid)
                }
                
                self.updateFetchProfileImageCompletionHandlers(person: uid)
                completion()
            }
        } else {
            if awaitingProfileImageFetches[uid] != nil {
                awaitingProfileImageFetches[uid]!.append(completion)
            } else {
                awaitingProfileImageFetches.updateValue([completion], forKey: uid)
            }
        }
    }
}
