//
//  Mention.swift
//  Smashtag
//
//  Created by Talha Baig on 8/20/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import Foundation
import CoreData
import Twitter

class Mention: NSManagedObject {

    class func mentionWithTwitterInfo(mention: Twitter.Mention, withTwitterInfo twitterInfo: Twitter.Tweet, andSearchText searchText: String, inContext context: NSManagedObjectContext) -> Mention? {
        
        let request =  NSFetchRequest(entityName: "Mention")
        request.predicate = NSPredicate(format: "keyword = %@ and searchText = %@", mention.keyword, searchText)
        
        if let men = (try? context.executeFetchRequest(request))?.first as? Mention {
            let count = men.count
            let newNumber = NSNumber(int: Int(count!) + 1)
            men.count! = newNumber
            return men
        } else if let men = NSEntityDescription.insertNewObjectForEntityForName("Mention", inManagedObjectContext: context) as? Mention {
            men.count = 1
            men.keyword = mention.keyword
            men.searchText = searchText
            return men
        }
        return nil
    }
}
