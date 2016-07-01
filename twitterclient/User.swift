//
//  User.swift
//  twitterclient
//
//  Created by Nicole Mitchell on 6/27/16.
//  Copyright © 2016 Nicole Mitchell. All rights reserved.
//

import UIKit

class User: NSObject {

    static let userDidLogoutNotification = "UserDidLogout"

    var name: NSString?
    var screenname: NSString?
    var profileUrl : NSURL?
    var profileURLString: String?
    var tagline: NSString?
    var profileBannerUrl: NSURL?
    var profileBannerURLString: String?
    var followersCount: Int?
    var followingCount: Int?
    var tweetsCount: Int?
    
    
    var dictionary: NSDictionary?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        name = dictionary["name"] as? String
        screenname = dictionary["screen_name"] as? String
        profileURLString = dictionary["profile_image_url_https"] as? String
        print ("string\(profileURLString)")
        if let profileURLString = profileURLString {
            profileUrl = NSURL(string: profileURLString)
        }
        tagline = dictionary["description"] as? String
        profileBannerURLString = dictionary["profile_banner_url"] as? String
        if let profileBannerURLString = profileBannerURLString {
            profileBannerUrl = NSURL(string: profileBannerURLString)
        }
        followersCount = dictionary["followers_count"] as! Int
        followingCount = dictionary["friends_count"] as! Int
        tweetsCount = dictionary["statuses_count"] as! Int

        
    }
    
    static var _currentUser: User?
    
    class var currentUser: User? {
        get {
            if _currentUser == nil {
                let defaults = NSUserDefaults.standardUserDefaults()
                let userData = defaults.objectForKey("currentUserData") as? NSData
                
                if let userData = userData {
                    let dictionary = try! NSJSONSerialization.JSONObjectWithData(userData, options: []) as! NSDictionary
                    _currentUser = User(dictionary: dictionary)
                }
            }
            return _currentUser
        }
        
        set (user) {
            _currentUser = user
            let defaults = NSUserDefaults.standardUserDefaults()
            
            if let user = user {
                let data = try! NSJSONSerialization.dataWithJSONObject(user.dictionary!, options: [])
                defaults.setObject(data, forKey: "currentUserData")
            } else {
                defaults.setObject(nil, forKey: "currentUserData")
            }
        
            defaults.synchronize()
        }
    }
    
    
}
