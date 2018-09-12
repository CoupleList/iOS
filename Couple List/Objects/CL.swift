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

class CL {
    
    static let shared = CL()
    
    var userSettings: UserSettings = UserSettings.init(listKey: "", listCode: "")!
    var profileDisplayNames = [String:String]()
    var profileImages = [String:UIImage]()
    
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
}
