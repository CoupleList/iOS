//
//  ActivitiesViewController.swift
//  Couple List
//
//  Created by Kirin Patel on 6/17/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit
import GoogleMobileAds

class ActivityNavigationViewController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.prefersLargeTitles = true
        toolbar.barStyle = .black
        navigationBar.barStyle = .black
        navigationBar.tintColor = .white
        
        if !CL.shared.noAds() {
            loadBannerView()
        }
        
        pushViewController(ActivitiesTableViewController(), animated: true)
    }
    
    fileprivate func loadBannerView() {
        let bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView.delegate = self
        bannerView.adUnitID = "ca-app-pub-9026572937829340/1144713796"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        toolbar.addSubview(bannerView)
    }
}

extension ActivityNavigationViewController: GADBannerViewDelegate {
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        UIView.animate(withDuration: 0.5) {
            self.isToolbarHidden = false
        }
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        isToolbarHidden = true
    }
}
