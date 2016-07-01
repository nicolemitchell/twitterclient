//
//  TweetCell.swift
//  twitterclient
//
//  Created by Nicole Mitchell on 6/28/16.
//  Copyright © 2016 Nicole Mitchell. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {

    @IBOutlet weak var tweetProfPic: UIImageView!
    @IBOutlet weak var tweetTimestamp: UILabel!
    @IBOutlet weak var tweetScreenname: UILabel!
    @IBOutlet weak var tweetName: UILabel!
    @IBOutlet weak var tweetText: UILabel!
    
    @IBOutlet weak var retweeterLabel: UILabel!
    @IBOutlet weak var retweeterIcon: UIImageView!
    
    var tweet: Tweet?
    
    @IBOutlet weak var retweetButton: UIButton!
    @IBAction func onRetweet(sender: AnyObject) {
        if tweet!.retweetBool == false {
            tweet?.retweet({
                dispatch_async(dispatch_get_main_queue()){
                    self.retweetButton.selected = true
                    self.retweetCountLabel.text = String(self.tweet!.retweetCount)
                }
                }, failure: { (error: NSError) in
                
                    
            })
        } else {
            tweet?.unretweet({
                dispatch_async(dispatch_get_main_queue()){
                    self.retweetButton.selected = false
                    self.retweetCountLabel.text = String(self.tweet!.retweetCount)
                }
                }, failure: { (error:NSError) in
                    
            })
        }
    }
    
    @IBOutlet weak var retweetCountLabel: UILabel!
    
    @IBOutlet weak var favoriteButton: UIButton!

    @IBAction func onFavorite(sender: AnyObject) {
        if tweet!.favoriteBool == false {
            tweet?.favorite({
                dispatch_async(dispatch_get_main_queue()){
                    self.favoriteButton.selected = true
                    self.favoriteCountLabel.text = String(self.tweet!.favoritesCount)
                }
                }, failure: { (error: NSError) in
                    
            })
        } else {
            tweet?.unfavorite({
                dispatch_async(dispatch_get_main_queue()){
                    self.favoriteButton.selected = false
                    self.favoriteCountLabel.text = String(self.tweet!.favoritesCount)
                }
                }, failure: { (error: NSError) in
                    
            })
        }
    }
    @IBOutlet weak var favoriteCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
