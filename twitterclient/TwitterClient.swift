//
//  TwitterClient.swift
//  twitterclient
//
//  Created by Nicole Mitchell on 6/27/16.
//  Copyright © 2016 Nicole Mitchell. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class TwitterClient: BDBOAuth1SessionManager {
    
    static let sharedInstance = TwitterClient(baseURL: NSURL(string: "https://api.twitter.com"), consumerKey: "Jsar5NB0nZjWQhK9fGG6eBJ1c", consumerSecret: "kfnQHZ2gblvaCo1GkYwZo6fytobvqvdYOuVcT2c0nTz4AfhEAi")

    var loginSuccess: (() -> ())?
    var loginFailure: ((NSError) -> ())?
    
    func login(success: () -> (), failure: (NSError) -> ()) {
        loginSuccess = success
        loginFailure = failure
        
        TwitterClient.sharedInstance.deauthorize()
        TwitterClient.sharedInstance.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "twitterclient://oauth"), scope: nil, success: { (requestToken:BDBOAuth1Credential!) -> Void in
            let url = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")!
            UIApplication.sharedApplication().openURL(url)
            
        }) { (error: NSError!) -> Void in
            print("error\(error.localizedDescription)")
            self.loginFailure?(error)
        }
    }
    
    func logout() {
        User.currentUser = nil
        deauthorize()
        NSNotificationCenter.defaultCenter().postNotificationName(User.userDidLogoutNotification, object: nil)
    }
    
    func handleOpenUrl(url: NSURL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken:BDBOAuth1Credential!) -> Void in

            self.currentAccount({ (user: User) in
                User.currentUser = user
                self.loginSuccess?()
            }, failure: { (error: NSError) in
                self.loginFailure?(error)
            })
        }) { (error: NSError!) -> Void in
            print("error: \(error.localizedDescription)")
            self.loginFailure?(error)
        }
    }
    
    func homeTimeline(success: ([Tweet])->(), failure: (NSError) ->()) {
        
        GET("1.1/statuses/home_timeline.json", parameters: nil, progress: nil, success: { (task:NSURLSessionDataTask, response: AnyObject?) in
            let tweetsDictionaries = response as! [NSDictionary]
            let tweets = Tweet.tweetsWithArray(tweetsDictionaries)

            success(tweets)
            
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
                print("error:\(error.localizedDescription)")
                
        })
        
    }
    
    func currentAccount(success: (User) -> (), failure: (NSError) -> ()) {
        GET("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            let userDictionary = response as! NSDictionary
            
            let user = User(dictionary: userDictionary)
            
            success(user)
            
        }, failure: { (task:NSURLSessionDataTask?, error: NSError) -> Void in
            failure(error)
        })
    }
    
    func postStatus(tweetText: String, success: () -> (), failure: (NSError) -> ()) {
        POST("1.1/statuses/update.json", parameters: ["status": tweetText], progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            success()
        }, failure: { (task:NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
        })
    }
    
    func getRateStatuses(handler: ((response: NSDictionary?, error: NSError?) -> Void)) {
        GET("1.1/application/rate_limit_status.json?resources=statuses", parameters:nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                if let dict = response as? NSDictionary {
                    handler(response:dict, error:nil)
                }
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                handler(response:nil, error:error)
        })
    }
    
    private static let ratePrintLabels = [
        "/statuses/home_timeline":"home timeline",
        "/statuses/retweets/:id":"retweet",
        "/statuses/user_timeline":"user timeline"]
    
    func printRateStatuses() {
        self.getRateStatuses { (response, error) in
            if let error = error {
                print("received error getting rate limits")
            }else{
                if let response = response {
                    for (key,value) in TwitterClient.ratePrintLabels {
                        if let resourcesDict = response["resources"] as? NSDictionary {
                            if let statusDict = resourcesDict["statuses"] as? NSDictionary {
                                if let keyDict = statusDict[key] as? NSDictionary {
                                    let limit = keyDict["limit"] as! Int
                                    let remaining = keyDict["remaining"] as! Int
                                    let epoch = keyDict["reset"] as! Int
                                    let resetDate = NSDate(timeIntervalSince1970: Double(epoch))
                                    print("\(value) rate: limit=\(limit), remaining=\(remaining); expires in \(TwitterClient.formatIntervalElapsed(resetDate.timeIntervalSinceNow))")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private static var elapsedTimeFormatter: NSDateComponentsFormatter = {
        let formatter = NSDateComponentsFormatter()
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyle.Abbreviated
        formatter.collapsesLargestUnit = true
        formatter.maximumUnitCount = 1
        return formatter
    }()
    
    static func formatTimeElapsed(sinceDate: NSDate) -> String {
        let interval = NSDate().timeIntervalSinceDate(sinceDate)
        return elapsedTimeFormatter.stringFromTimeInterval(interval)!
    }
    
    static func formatIntervalElapsed(interval: NSTimeInterval) -> String {
        return elapsedTimeFormatter.stringFromTimeInterval(interval)!
    }
    
}
