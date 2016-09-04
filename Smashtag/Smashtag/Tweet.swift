//
//  Tweet.swift
//  Smashtag
//
//  Created by Talha Baig on 8/20/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import Foundation
import CoreData
import Twitter


class Tweet: NSManagedObject {

    class func tweetWithTwitterInfoAndSearchText(twitterInfo: Twitter.Tweet, andSearchText searchText: String, inContext context: NSManagedObjectContext) -> Tweet? {
        
        let request = NSFetchRequest(entityName: "Tweet")
        request.predicate = NSPredicate(format: "id = %@", twitterInfo.id)
        
     if let tweet = (try? context.executeFetchRequest(request))?.first as? Tweet {
        return tweet

    } else if let tweet = NSEntityDescription.insertNewObjectForEntityForName("Tweet", inManagedObjectContext: context) as? Tweet{
            tweet.id = twitterInfo.id
            tweet.text = twitterInfo.text
            let set = NSMutableSet()
            for mention in twitterInfo.userMentions{
                if let men = Mention.mentionWithTwitterInfo(mention, withTwitterInfo: twitterInfo, andSearchText: searchText, inContext: context){
                    set.addObject(men)
                }
            }
            for mention in twitterInfo.hashtags {
                if let men = Mention.mentionWithTwitterInfo(mention, withTwitterInfo: twitterInfo, andSearchText: searchText, inContext: context){
                    set.addObject(men)
                }
            }
            tweet.mentions = set
            return tweet
        }
        return nil
    }
}
