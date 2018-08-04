//
//  Products.swift
//  Couple List
//
//  Created by Kirin Patel on 6/9/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import Foundation

public struct Products {
    
    public static let RemoveAds = "remove_ads"
    
    fileprivate static let productIdentifiers: Set<ProductIdentifier> = [Products.RemoveAds]
    
    public static let store = PurchaseHelper(productIds: Products.productIdentifiers)
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}

