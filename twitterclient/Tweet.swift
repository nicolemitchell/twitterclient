//
//  Tweet.swift
//  twitterclient
//
//  Created by Nicole Mitchell on 6/27/16.
//  Copyright © 2016 Nicole Mitchell. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    
    var text: NSString?
    var user: User?
    var retweeter: User?
    var name: NSString?
    var screenname: NSString?
    var profileUrl: NSURL?
    var profileURLString: String?
    var timestamp: NSDate?
    var retweetCount: Int = 0
    var favoritesCount: Int = 0
    var id: Int = 0
    var retweetBool: Bool?
    var favoriteBool: Bool?
    
    init(dictionary: NSDictionary) {
        print("dict")
        print(dictionary)
        
        
        text = dictionary["retweeted_status"]?["text"] as? String ?? dictionary["text"] as? String
        
        if let dict = dictionary["retweeted_status"]?["user"] as? NSDictionary {
            self.retweeter = User(dictionary: (dictionary["user"] as? NSDictionary)!)
            self.user = User(dictionary: dict)
        } else {
            self.retweeter = nil
            self.user = User(dictionary: (dictionary["user"] as? NSDictionary!)!)
        }

        name = user!.name as? String
        print(name)
        screenname = user!.screenname as? String
        print(screenname)
        profileUrl = user!.profileUrl
        print(profileUrl!)
        
        profileURLString = user!.profileURLString
        print(profileURLString)
        
        id = (dictionary["retweeted_status"]?["id"] ?? dictionary["id"]) as? Int ?? 0
        
        retweetBool = (dictionary["retweeted_status"]?["retweeted"] ?? dictionary["retweeted"]) as? Bool
        favoriteBool = (dictionary["retweeted_status"]?["favorited"] ?? dictionary["favorited"]) as? Bool
        
        retweetCount = (dictionary["retweeted_status"]?["retweet_count"] ?? dictionary["retweet_count"]) as? Int ?? 0
        favoritesCount = (dictionary["retweeted_status"]?["favorite_count"] ?? dictionary["favorite_count"]) as? Int ?? 0
        
        let timestampString = (dictionary["retweeted_status"]?["created_at"] ?? dictionary["created_at"]) as? String
        let formatter = NSDateFormatter()
        if let timestampString = timestampString {
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            timestamp = formatter.dateFromString(timestampString)
        }
        
    }
    
    class func tweetsWithArray(dictionaries: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in dictionaries {
            let tweet = Tweet(dictionary: dictionary)
            tweets.append(tweet)
            
        }
        
        return tweets
    }
    
    func retweet(success: ()->(), failure: (NSError) ->()) {
        TwitterClient.sharedInstance.POST("1.1/statuses/retweet/\(id).json", parameters: nil, progress: nil, success: { (task:NSURLSessionDataTask, response: AnyObject?) in
            
            self.retweetBool = true
            self.retweetCount += 1
            
            success()
            print ("success")
            
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
                print("error:\(error.localizedDescription)")
                
        })
        
    }
    
    func unretweet(success: ()->(), failure: (NSError) ->()) {
        TwitterClient.sharedInstance.POST("1.1/statuses/unretweet/\(id).json", parameters: nil, progress: nil, success: { (task:NSURLSessionDataTask, response: AnyObject?) in
            
            self.retweetBool = false
            self.retweetCount -= 1
            
            success()
            
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
                print("error:\(error.localizedDescription)")
                
        })
        
    }
    
    func favorite(success: ()->(), failure: (NSError) ->()) {
        TwitterClient.sharedInstance.POST("1.1/favorites/create.json?id=\(id)", parameters: nil, progress: nil, success: { (task:NSURLSessionDataTask, response: AnyObject?) in
            
            self.favoriteBool = true
            self.favoritesCount += 1
            
            success()
            
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
                print("error:\(error.localizedDescription)")
                
        })
        
    }
    
    func unfavorite(success: ()->(), failure: (NSError) ->()) {
        TwitterClient.sharedInstance.POST("1.1/favorites/destroy.json?id=\(id)", parameters: nil, progress: nil, success: { (task:NSURLSessionDataTask, response: AnyObject?) in
            
            self.favoriteBool = false
            self.favoritesCount -= 1
            
            success()
            
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
                print("error:\(error.localizedDescription)")
                
        })
        
    }



}
