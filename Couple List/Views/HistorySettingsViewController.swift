//
//  HistorySettingsViewController.swift
//  Couple List
//
//  Created by Kirin Patel on 8/2/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit

class HistorySettingsViewController: UIViewController {
    
    let queryLimitPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.numberOfRows(inComponent: 4)
        return pickerView
    }()
    
    var queryLimit: UInt = 25 {
        didSet {
            switch queryLimit {
            case 0:
                queryLimitPickerView.selectedRow(inComponent: 4)
                break
            case 50:
                queryLimitPickerView.selectedRow(inComponent: 1)
                break
            case 75:
                queryLimitPickerView.selectedRow(inComponent: 2)
                break
            case 100:
                queryLimitPickerView.selectedRow(inComponent: 3)
                break
            default:
                queryLimitPickerView.selectedRow(inComponent: 0)
                break
            }
        }
    }
    
    var delegate: HistoryTableViewControllerDelegate!
    
    let queryLimits: [String] = [
        "25",
        "50",
        "75",
        "100",
        "All"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(named: "MainColor")
        title = "History Settings"
        
        view.addSubview(queryLimitPickerView)
        queryLimitPickerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        queryLimitPickerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        queryLimitPickerView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
    }
}

extension HistorySettingsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return queryLimits.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return queryLimits[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch row {
        case 1:
            delegate.updateHistoryQueryLimit(forLast: 50)
            break
        case 2:
            delegate.updateHistoryQueryLimit(forLast: 75)
            break
        case 3:
            delegate.updateHistoryQueryLimit(forLast: 100)
            break
        case 4:
            delegate.updateHistoryQueryLimit(forLast: 0)
            break
        default:
            delegate.updateHistoryQueryLimit(forLast: 25)
            break
        }
    }
}
