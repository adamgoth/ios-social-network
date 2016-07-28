//
//  PostCell.swift
//  ios-social-network
//
//  Created by Adam Goth on 7/22/16.
//  Copyright © 2016 Adam Goth. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showcaseImg: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    @IBOutlet weak var removeLbl: UILabel!
    
    var post: Post!
    var request: Request?
    var likeRef: FIRDatabaseReference!
    var postRef: FIRDatabaseReference!
    var delegate: FeedVC?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: "likeTapped:")
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.userInteractionEnabled = true
        
        let removeTap = UITapGestureRecognizer(target: self, action: "removeTapped:")
        removeTap.numberOfTapsRequired = 1
        removeLbl.addGestureRecognizer(removeTap)
        removeLbl.userInteractionEnabled = true
        
    }
    
    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        showcaseImg.clipsToBounds = true
    }

    func configureCell(post: Post, img: UIImage?) {
        self.post = post
        likeRef = DataService.ds.ref_current_user.child("likes").child(post.postKey)
        postRef = DataService.ds.posts_ref.child(post.postKey)
        self.descriptionText.text = post.postDescription
        self.likesLbl.text = "\(post.likes)"
        
        if post.imageUrl != nil {
            
            if img != nil {
                self.showcaseImg.image = img
            } else {
                
                request = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    
                    if err == nil {
                        let img = UIImage(data: data!)!
                        self.showcaseImg.image = img
                        FeedVC.imageCache.setObject(img, forKey: self.post.imageUrl!)
                    } else {
                        print(err.debugDescription)
                    }
                })
                
            }
        } else {
            self.showcaseImg.hidden = true
        }
        
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if let doesNotExist = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "heart-empty")
            } else {
                self.likeImg.image = UIImage(named: "heart-full")
            }
            
        })
        
        
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if let doesNotExist = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "heart-full")
                self.post.adjustLikes(true)
                self.likeRef.setValue(true)
            } else {
                self.likeImg.image = UIImage(named: "heart-empty")
                self.post.adjustLikes(false)
                self.likeRef.removeValue()
            }
            
        })
    }
    
    func removeTapped(sender: UITapGestureRecognizer) {
        let alertController = UIAlertController(title: "Delete post?", message: "You cannot undo this action.", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            print("Canceled action")
        }
        alertController.addAction(cancelAction)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            self.postRef.removeValue()
            print("Post removed")
        }
        alertController.addAction(OKAction)
        
        delegate?.showRemoveAlert(alertController)
    }

}
