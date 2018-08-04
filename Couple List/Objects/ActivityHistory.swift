//
//  ActivityHistory.swift
//  Couple List
//
//  Created by Kirin Patel on 7/5/18.
//  Copyright © 2018 Kirin Patel. All rights reserved.
//

import UIKit

enum State {
    case deleted
    case created
    case edited
    case completed
}

fileprivate let states: [Int:State] = [
    -1: State.deleted,
    1: State.created,
    2: State.edited,
    3: State.completed
]

class ActivityHistory: NSObject {
    
    var time: Int
    var state: State
    var before: Activity?
    var after: Activity?
    
    init?(time: Int, state: Int) {
        self.time = time
        self.state = states[state]!
    }
}
