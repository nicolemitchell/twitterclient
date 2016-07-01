//
//  ProfileViewController.swift
//  twitterclient
//
//  Created by Nicole Mitchell on 6/29/16.
//  Copyright © 2016 Nicole Mitchell. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var tweet: Tweet!
    var user: User!
    
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var tweetsCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    
    @IBOutlet weak var tweetsTableView: UITableView!

    var tweets: [Tweet] = []
    var viewOptions = ["1.1/statuses/user_timeline.json", "1.1/statuses/mentions_timeline.json", "1.1/favorites/list.json"]
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        
        var endpoint = ""

        switch sender.selectedSegmentIndex {
        case 0:
            endpoint = "1.1/statuses/user_timeline.json"
        case 1:
            endpoint = "1.1/statuses/mentions_timeline.json"
        case 2:
            endpoint = "1.1/favorites/list.json"
        default:
            break;
        }  //Switch
        loadData(user.screenname!, endpoint: endpoint)
        print(tweets)
        
    } // indexChanged for the Segmented Control

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        var nav = self.navigationController?.navigationBar
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "TwitterLogo")
        imageView.image = image
        navigationItem.titleView = imageView
        
        tweetsTableView.dataSource = self
        tweetsTableView.delegate = self
        
        self.tweetsTableView.rowHeight = UITableViewAutomaticDimension
        self.tweetsTableView.estimatedRowHeight = 144
        
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tweetsTableView.insertSubview(refreshControl, atIndex: 0)
        
        
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
        
        tweetsCountLabel.text = String(user!.tweetsCount as! Int!)
        followersCountLabel.text = String(user!.followersCount as! Int!)
        followingCountLabel.text = String(user!.followingCount as! Int!)
        
        
        loadData(user.screenname!, endpoint: "1.1/statuses/user_timeline.json")

    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        // Reload the tableView now that there is new data
        loadData(user.screenname!, endpoint: viewOptions[segmentedControl.selectedSegmentIndex])
        
        // Tell the refreshControl to stop spinning
        refreshControl.endRefreshing()
    }
    
    
    func showFilteredTweets(screenname: NSString, endpoint: String, success: ([Tweet])->(), failure: (NSError) ->()) {

        TwitterClient.sharedInstance.GET(endpoint, parameters: ["screen_name": screenname], progress: nil, success: { (task:NSURLSessionDataTask, response: AnyObject?) in
        let tweetsDictionaries = response as! [NSDictionary]
        let tweets = Tweet.tweetsWithArray(tweetsDictionaries)
        
        print(tweets)
        
        success(tweets)
        
        }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
        failure(error)
        print("error:\(error.localizedDescription)")
        
        })
    }
    
    func loadData(screenname: NSString, endpoint: String) {
        showFilteredTweets(screenname, endpoint: endpoint, success: { (tweets: [Tweet]) -> () in
            self.tweets = tweets
            self.tweetsTableView.reloadData()
        }, failure: { (error: NSError) -> () in
            print(error.localizedDescription)
        })
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("tweetCell", forIndexPath: indexPath) as! TweetCell
        //print (self.tweets)
        
        let tweet = self.tweets[indexPath.row]
        print(tweet)
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
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
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
