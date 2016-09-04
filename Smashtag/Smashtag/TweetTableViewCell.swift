//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by CS193p Instructor.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell{
    
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    
    var userMentionsColor = UIColor.blueColor()
    var hashtagsColor = UIColor.blueColor()
    var urlsColor = UIColor.blueColor()
    
    var tweet: Twitter.Tweet? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI(){
        // reset any existing tweet information
        tweetTextLabel?.attributedText = nil
        tweetScreenNameLabel?.text = nil
        tweetProfileImageView?.image = nil
        tweetCreatedLabel?.text = nil
        
        // load new information from our tweet (if any)
        if let tweet = self.tweet{
            tweetTextLabel?.text = tweet.text
            if tweetTextLabel?.text != nil  {
                for _ in tweet.media {
                    tweetTextLabel.text! += " 📷"
                }
                //changes the color of mentions to the three teams in pokemon!!!!
                let attributedString = NSMutableAttributedString(attributedString: tweetTextLabel.attributedText!)
                convertMentionToDifferentColor(attributedString, mentions: tweet.userMentions, color: userMentionsColor)
                convertMentionToDifferentColor(attributedString, mentions: tweet.hashtags, color: hashtagsColor)
                convertMentionToDifferentColor(attributedString, mentions: tweet.urls, color: urlsColor)
                tweetTextLabel.attributedText = attributedString
            }
            
            tweetScreenNameLabel?.text = "\(tweet.user)" // tweet.user.description
            
            if let profileImageURL = tweet.user.profileImageURL {
                if let imageData = NSData(contentsOfURL: profileImageURL) { // blocks main thread!
                    tweetProfileImageView?.image = UIImage(data: imageData)
                }
            }
            
            let formatter = NSDateFormatter()
            if NSDate().timeIntervalSinceDate(tweet.created) > 24*60*60 {
                formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            } else {
                formatter.timeStyle = NSDateFormatterStyle.ShortStyle
            }
            tweetCreatedLabel?.text = formatter.stringFromDate(tweet.created)
        }

    }
     /* Converts the Mutable String to have different colors based on mentions 
     */
    private func convertMentionToDifferentColor (attributedString: NSMutableAttributedString, mentions: [Twitter.Mention], color: UIColor){
        for mention in mentions{
            if tweetTextLabel.text!.containsString(mention.keyword){
                attributedString.addAttribute(NSForegroundColorAttributeName, value: color, range: mention.nsrange)
            }
        }
    }
}
