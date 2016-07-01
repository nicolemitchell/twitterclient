//
//  ComposeViewController.swift
//  twitterclient
//
//  Created by Nicole Mitchell on 6/30/16.
//  Copyright © 2016 Nicole Mitchell. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var profImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var characterLabel: UILabel!
    
    @IBOutlet weak var characterWarning: UIView!
    
    var tweetText: String!
    
    @IBAction func onTweet(sender: AnyObject) {
        
        tweetText = textView.text
        
        TwitterClient.sharedInstance.postStatus(tweetText, success: { 
            self.dismissViewControllerAnimated(true) {
            }

        }) { (error:NSError) in
            print("error\(error.description)")
        }
    }
    
    
    @IBAction func onClose(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true) { 
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.delegate = self
        // Do any additional setup after loading the view.
        characterWarning.hidden = true
        characterLabel.text = "140"
        
        profImageView.setImageWithURL((User.currentUser?.profileUrl)!)
        
    }
    
    func textViewDidChange(textView: UITextView) {
        print(textView.text.characters.count)
        var characterCount = 140 - textView.text.characters.count
        characterLabel.text = String(characterCount)
        
        if characterCount < 0 {
            characterWarning.hidden = false
        }
        if characterCount >= 0 {
            characterWarning.hidden = true
        }
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
