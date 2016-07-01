//
//  ProfileViewController.swift
//  twitterclient
//
//  Created by Nicole Mitchell on 6/29/16.
//  Copyright © 2016 Nicole Mitchell. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    
    var tweet: Tweet!
    var user: User!
    
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        bannerImageView.layer.zPosition = -2
        
        if tweet?.user != nil {
            user = tweet!.user
        } else {
            user = User.currentUser
        }
        print(user)
        if user!.profileBannerURLString != nil {
            bannerImageView.setImageWithURL(user!.profileBannerUrl!)
        }
        profileImageView.setImageWithURL(user!.profileUrl!)
        nameLabel.text = user!.name as! String
        screennameLabel.text = "@" + (user!.screenname as! String)
        descriptionLabel.text = user!.tagline as! String
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
