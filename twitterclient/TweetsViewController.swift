//
//  TweetsViewController.swift
//  twitterclient
//
//  Created by Nicole Mitchell on 6/28/16.
//  Copyright © 2016 Nicole Mitchell. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var tweets: [Tweet] = []
    
    @IBOutlet weak var FeedTableView: UITableView!
    

    @IBAction func onRetweet(sender: AnyObject) {
        FeedTableView.reloadData()
    }
    
    @IBAction func onFavorite(sender: AnyObject) {
        FeedTableView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        FeedTableView.dataSource = self
        FeedTableView.delegate = self
        
        self.FeedTableView.rowHeight = UITableViewAutomaticDimension
        self.FeedTableView.estimatedRowHeight = 144
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        FeedTableView.insertSubview(refreshControl, atIndex: 0)
        
        loadData()
        
    }
    
    func viewDidAppear() {
        FeedTableView.reloadData()
    }
    
    func viewWillAppear() {
        FeedTableView.reloadData()
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        // Reload the tableView now that there is new data
        loadData()
        
        // Tell the refreshControl to stop spinning
        refreshControl.endRefreshing()
    }
    
    func loadData() {
        TwitterClient.sharedInstance.homeTimeline({ (tweets: [Tweet]) -> () in
            self.tweets = tweets
            self.FeedTableView.reloadData()

            //for tweet in tweets {
                //print(tweet.text)
            //}
            }, failure: { (error: NSError) -> () in
                print(error.localizedDescription)
        })
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("tweetCell", forIndexPath: indexPath) as! TweetCell
        //print (self.tweets)
        
        let tweet = self.tweets[indexPath.row]
        cell.tweet = tweet
        cell.tweetText.text = tweet.text as! String
        print("tweet text")
        print (tweet.text)
        cell.tweetName.text = tweet.name as! String
        cell.tweetScreenname.text = "@" + (tweet.screenname as! String)
        
        if tweet.retweeter != nil {
            cell.retweeterLabel.hidden = false
            cell.retweeterIcon.hidden = false
            cell.retweeterLabel.text = (tweet.retweeter!.name as! String)+" Retweeted"
        } else {
            cell.retweeterLabel.hidden = true
            cell.retweeterIcon.hidden = true
            cell.retweeterLabel.text = nil
        }
        
        let timestamp = tweet.timestamp! as NSDate
        
        let todaysDate:NSDate = NSDate()
        let timeSince = todaysDate.timeIntervalSinceDate(timestamp) as NSTimeInterval
        var timeText = ""
        
        if timeSince < 60 {
            let secSince = timeSince
            timeText = String(format:"%.0f", secSince) + "s"
        }
        else if timeSince < 3600 {
            let minSince = timeSince/60
            timeText = String(format:"%.0f", minSince) + "m"
        }
        else if timeSince < 86400 {
            let hoursSince = timeSince/3600
            timeText = String(format:"%.0f", hoursSince) + "h"
        }
        else if timeSince < 604800 {
            let daysSince = timeSince/86400
            timeText = String(format:"%.0f", daysSince) + "d"
        }
        else {
            let formatter = NSDateFormatter()
            formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            timeText = formatter.stringFromDate(timestamp)
        }
        
        cell.tweetTimestamp.text = timeText
        cell.tweetProfPic.setImageWithURL(tweet.profileUrl!)
        
        cell.retweetCountLabel.text = String(tweet.retweetCount)
        
        cell.favoriteCountLabel.text = String(tweet.favoritesCount)
        
        cell.retweetButton.selected = tweet.retweetBool!
        cell.favoriteButton.selected = tweet.favoriteBool!
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogoutButton(sender: AnyObject) {
        
        TwitterClient.sharedInstance.logout()
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "feedDetailSegue" {
            let cell = sender as! UITableViewCell
            let indexPath = FeedTableView.indexPathForCell(cell)
            let tweet = tweets[indexPath!.row]
            
            let detailViewController = segue.destinationViewController as! DetailViewController
            
            detailViewController.tweet = tweet
            
        
        }
        
        
        if segue.identifier == "feedProfileSegue" {
            let button = sender as! UIButton
            var indexPaths = []
            indexPaths = FeedTableView.indexPathsForRowsInRect(button.frame)!
            let indexPath = indexPaths[0]
            let tweet = tweets[indexPath.row]
            
            let profileViewController = segue.destinationViewController as! ProfileViewController
            
            profileViewController.tweet = tweet
            
        }
        
    }
    

}
