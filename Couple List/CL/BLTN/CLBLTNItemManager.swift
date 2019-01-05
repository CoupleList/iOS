//
//  CLBLTNManager.swift
//  Couple List
//
//  Created by Kirin Patel on 1/5/19.
//  Copyright © 2019 Kirin Patel. All rights reserved.
//

import UIKit
import Ambience
import BLTNBoard

class CLBLTNItemManager {
    
    var manager: BLTNItemManager!
    private var rootItem: CLBLTNPageItem!
    
    init(rootItem: CLBLTNPageItem) {
        self.rootItem = rootItem
        manager = BLTNItemManager(rootItem: rootItem)
    }
    
    func show(above: UIViewController) {
        rootItem.setTheme()
        setTheme()
        manager.showBulletin(above: above)
    }
    
    func dismiss() {
        manager.dismissBulletin()
    }
    
    func reset() {
        manager.popToRootItem()
    }
    
    func popItem() {
        manager.popItem()
    }
    
    func push(item: CLBLTNPageItem) {
        item.setTheme()
        manager.push(item: item)
    }
    
    func present(viewController: UIViewController) {
        manager.present(viewController, animated: true)
    }
    
    func displayActivityIndicator() {
        let color: UIColor = Ambience.currentState == .invert ? .white : .black
        manager.displayActivityIndicator(color: color)
    }
    
    func hideActivityIndicator() {
        manager.hideActivityIndicator()
    }
    
    fileprivate func setTheme() {
        if Ambience.currentState == .invert {
            manager.backgroundColor = .black
            manager.backgroundViewStyle = .blurredLight
        } else {
            manager.backgroundColor = .white
            manager.backgroundViewStyle = .blurredDark
        }
    }
}
