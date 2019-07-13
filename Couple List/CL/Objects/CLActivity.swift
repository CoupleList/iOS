//
//  CLActivity.swift
//  Couple List
//
//  Created by Kirin Patel on 1/3/19.
//  Copyright © 2019 Kirin Patel. All rights reserved.
//

import FirebaseDatabase

class CLActivity {
    
    var listRef: DatabaseReference
    var id: String
    var title: String
    var desc: String?
    var completed: Bool = false
    
    init(listRef: DatabaseReference, id: String, title: String) {
        self.listRef = listRef
        self.id = id
        self.title = title
    }
    
    init(listRef: DatabaseReference,
         id: String,
         title: String,
         desc: String? = "",
         completed: Bool? = false) {
        self.listRef = listRef
        self.id = id
        self.title = title
        self.desc = desc
        self.completed = completed ?? false
    }
    
    func update() {
        listRef.child(id).setValue([
            "title": title,
            "description": desc?.count ?? 0 > 0 ? desc : nil,
            "done": completed
            ])
    }
    
    func complete() {
        completed = true
        update()
    }
    
    func delete() {
        listRef.child(id).removeValue()
    }
}
