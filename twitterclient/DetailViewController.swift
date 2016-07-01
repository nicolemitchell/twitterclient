//
//  DetailViewController.swift
//  twitterclient
//
//  Created by Nicole Mitchell on 6/29/16.
//  Copyright © 2016 Nicole Mitchell. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var tweet: Tweet!

    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBAction func onProfileButton(sender: AnyObject) {
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var profpicImageView: UIImageView!
    
    @IBOutlet weak var retweeterIcon: UIImageView!
    
    @IBOutlet weak var retweeterLabel: UILabel!
    
    @IBOutlet weak var favoriteCountLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    

    @IBAction func onReply(sender: AnyObject) {
    }
    
    @IBAction func onRetweet(sender: AnyObject) {
        if tweet!.retweetBool == false {
            tweet?.retweet({
                self.retweetButton.selected = true
                self.retweetCountLabel.text = String(self.tweet!.retweetCount)
                }, failure: { (error: NSError) in
                    
            })
        } else {
            tweet?.unretweet({
                self.retweetButton.selected = false
                self.retweetCountLabel.text = String(self.tweet!.retweetCount)
                }, failure: { (error:NSError) in
                    
            })
        }
    }
    
    @IBAction func onFavorite(sender: AnyObject) {
        if tweet!.favoriteBool == false {
            tweet?.favorite({
                self.favoriteButton.selected = true
                self.favoriteCountLabel.text = String(self.tweet!.favoritesCount)
                }, failure: { (error: NSError) in
                    
            })
        } else {
            tweet?.unfavorite({
                self.favoriteButton.selected = false
                self.favoriteCountLabel.text = String(self.tweet!.favoritesCount)
                }, failure: { (error: NSError) in
                    
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if tweet != nil {
            
            self.tweetLabel.text = tweet.text as! String
            self.nameLabel.text = tweet.name as! String
            self.screennameLabel.text = "@" + (tweet.screenname as! String)
            
            if tweet.retweeter != nil {
                retweeterLabel.hidden = false
                retweeterIcon.hidden = false
                retweeterLabel.text = (tweet.retweeter!.name as! String)+" Retweeted"
            } else {
                retweeterLabel.hidden = true
                retweeterIcon.hidden = true
                retweeterLabel.text = nil
            }
    
            let timestamp = tweet.timestamp! as NSDate
            let formatter = NSDateFormatter()
            formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            formatter.timeStyle = NSDateFormatterStyle.ShortStyle
            let timeText = formatter.stringFromDate(timestamp) 
            
            self.timestampLabel.text = timeText
            self.profpicImageView.setImageWithURL(tweet.profileUrl!)
            
            retweetCountLabel.text = String(tweet.retweetCount)
            
            favoriteCountLabel.text = String(tweet.favoritesCount)
            
            retweetButton.selected = tweet.retweetBool!
            favoriteButton.selected = tweet.favoriteBool!
            

        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "detailProfileSegue" {
            
            let profileViewController = segue.destinationViewController as! ProfileViewController
            
            profileViewController.tweet = tweet
            
        }
        if segue.identifier == "detailReplySegue" {
            let composeViewController = segue.destinationViewController as! ComposeViewController
            
            composeViewController.tweet = tweet

        }
        
    }
    

}
