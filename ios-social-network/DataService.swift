//
//  DataService.swift
//  ios-social-network
//
//  Created by Adam Goth on 7/22/16.
//  Copyright © 2016 Adam Goth. All rights reserved.
//

import Foundation
import Firebase

class DataService {

    static let ds = DataService()
    
    private var _ref = FIRDatabase.database().reference()
    private var _posts_ref = FIRDatabase.database().referenceFromURL("https://ios-social-network.firebaseio.com/posts")
    
    var ref: FIRDatabaseReference {
        return _ref
    }
    
    var posts_ref: FIRDatabaseReference {
        return _posts_ref
    }
    
    func createFirebaseUser(uid: String, user: Dictionary<String, String>) {
        ref.child("users").child(uid).setValue(user)
    }
}