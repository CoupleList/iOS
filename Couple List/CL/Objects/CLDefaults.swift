//
//  CLDefaults.swift
//  Couple List
//
//  Created by Kirin Patel on 1/3/19.
//  Copyright © 2019 Kirin Patel. All rights reserved.
//

import FirebaseAuth
import FirebaseDatabase

enum CLDefaultsError: Error {
    case noUser
}

class CLDefaults {
    
    static let shared = CLDefaults()
    
    var list: CLList?
    
    private let ref = Database.database().reference()
    
    private init() { }
    
    func checkForListForUser(completion: @escaping (_ list: CLList?) -> Void) throws {
        if let user = Auth.auth().currentUser {
            ref.child("users/\(user.uid)").observeSingleEvent(of: .value) { snapshot in
                if snapshot.hasChild("list") && snapshot.hasChild("list/key") && snapshot.hasChild("list/code") {
                    if let key = snapshot.childSnapshot(forPath: "list/key").value as? String, let code = snapshot.childSnapshot(forPath: "list/code").value as? String {
                        self.validateUserHasPermissionsToViewList(key: key, completion: { canView in
                            if canView {
                                self.list = CLList(key: key, code: code)
                                completion(self.list)
                            } else {
                                completion(nil)
                            }
                        })
                    } else {
                        completion(nil)
                    }
                } else {
                    snapshot.children.allObjects.forEach {
                        if let childSnapshot = $0 as? DataSnapshot {
                            if childSnapshot.hasChild("code") {
                                let key = childSnapshot.key
                                let code = childSnapshot.childSnapshot(forPath: "code").value as? String ?? ""
                                if !code.isEmpty {
                                    self.validateUserHasPermissionsToViewList(key: key, completion: { canView in
                                        if canView {
                                            self.list = CLList(key: key, code: code)
                                            self.updateUserListSettings(uid: user.uid)
                                            return completion(self.list)
                                        } else {
                                            return completion(nil)
                                        }
                                    })
                                } else {
                                    return completion(nil)
                                }
                            }
                        } else {
                            return completion(nil)
                        }
                    }
                    completion(nil)
                }
            }
        } else {
            throw CLDefaultsError.noUser
        }
    }
    
    func createList(completion: @escaping (_ error: Error?) -> Void) throws {
        if let user = Auth.auth().currentUser {
            let key = ref.child("user/\(user.uid)").childByAutoId().key
            let code = String(ref.child("user/\(user.uid)/list").childByAutoId().key.shuffled())
            ref.child("users/\(Auth.auth().currentUser!.uid)/list").setValue([
                "key": key,
                "code": code
                ], withCompletionBlock: { (error, snapshot) in
                    guard error == nil else {
                        completion(error)
                        return
                    }
                    self.ref.child("lists/\(key)/code").setValue(code, withCompletionBlock: { (error, snapshot) in
                        guard error == nil else {
                            completion(error)
                            return
                        }
                        completion(nil)
                    })
            })
        } else {
            throw CLDefaultsError.noUser
        }
    }
    
    func leaveList() throws {
        if let user = Auth.auth().currentUser {
            ref.child("users/\(user.uid)/list").removeValue()
        } else {
            throw CLDefaultsError.noUser
        }
    }
    
    fileprivate func validateUserHasPermissionsToViewList(key: String, completion: @escaping (_ canView: Bool) -> Void) {
        ref.child("lists/\(key)").observeSingleEvent(of: .value, with: { _ in
            completion(true)
        }, withCancel: { _ in
            completion(false)
        })
    }
    
    fileprivate func updateUserListSettings(uid: String) {
        if let list = list {
            ref.child("users/\(uid)/list").setValue(["key": list.key,
                                                     "code": list.code])
        }
    }
}
