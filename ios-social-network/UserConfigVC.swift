//
//  UserConfigVC.swift
//  ios-social-network
//
//  Created by Adam Goth on 7/28/16.
//  Copyright © 2016 Adam Goth. All rights reserved.
//

import UIKit
import Firebase

class UserConfigVC: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    
    var userRef: FIRDatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userRef = DataService.ds.ref_current_user.child("username")

    }

    override func viewDidAppear(animated: Bool) {
        userRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let doesNotExist = snapshot.value as? NSNull {
                print("Need to set username")
            } else {
                self.performSegueWithIdentifier(SEGUE_USER_COMPLETE, sender: nil)
            }
        })
    }
    
    @IBAction func createUserTapped(sender: UIButton) {
        userRef.setValue(usernameField.text)
        self.performSegueWithIdentifier(SEGUE_USER_COMPLETE, sender: nil)
    }

}
