//
//  UserConfigVC.swift
//  ios-social-network
//
//  Created by Adam Goth on 7/28/16.
//  Copyright © 2016 Adam Goth. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class UserConfigVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var selectImageBtn: UIButton!
    
    var imagePicker: UIImagePickerController!
    
    var usernameRef: FIRDatabaseReference!
    var profileImgRef: FIRDatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        usernameRef = DataService.ds.ref_current_user.child("username")
        profileImgRef = DataService.ds.ref_current_user.child("profileImgUrl")
    }

    override func viewDidAppear(animated: Bool) {
        usernameRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let doesNotExist = snapshot.value as? NSNull {
                print("Need to set username")
            } else {
                self.performSegueWithIdentifier(SEGUE_USER_COMPLETE, sender: nil)
            }
        })
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        profileImg.image = image
        selectImageBtn.hidden = true
    }
    
    @IBAction func selectImage(sender: AnyObject) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func createUserTapped(sender: UIButton) {
        usernameRef.setValue(usernameField.text)
        
        if let img = profileImg.image {
            let urlStr = "https://post.imageshack.us/upload_api.php"
            let url = NSURL(string: urlStr)!
            let imgData = UIImageJPEGRepresentation(img, 0.2)!
            let keyData = "12DJKPSU5fc3afbd01b1630cc718cae3043220f3".dataUsingEncoding(NSUTF8StringEncoding)!
            let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
            
            Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
                
                multipartFormData.appendBodyPart(data: imgData, name: "fileupload", fileName: "image", mimeType: "image/jpg")
                multipartFormData.appendBodyPart(data: keyData, name: "key")
                multipartFormData.appendBodyPart(data: keyJSON, name: "format")
                
            }) { encodingResult in
                
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON(completionHandler: { response in
                        if let info = response.result.value as? Dictionary<String, AnyObject> {
                            if let links = info["links"] as? Dictionary<String, AnyObject> {
                                if let imgLink = links["image_link"] as? String {
                                    self.profileImgRef.setValue(imgLink)
                                }
                            }
                        }
                    })
                case .Failure(let error):
                    print(error)
                }
            }
        } else {
            print("Profile Image Found")
        }

        self.performSegueWithIdentifier(SEGUE_USER_COMPLETE, sender: nil)
    }

}
