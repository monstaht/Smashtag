//
//  MentionPopularityTableViewController.swift
//  Smashtag
//
//  Created by Talha Baig on 8/20/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import CoreData

class MentionPopularityTableViewController: CoreDataTableViewController {

    var mention: String? { didSet { updateUI() } }
    var managedObjectContext: NSManagedObjectContext? { didSet { updateUI() } }
    
    private func updateUI() {
        print("at update ui")
        if let context = managedObjectContext {
            let request = NSFetchRequest(entityName: "Mention")
            request.predicate = NSPredicate(format: "tweet.text contains[c] %@", mention!)
            request.sortDescriptors = [NSSortDescriptor(key: "count", ascending: false),
                                       NSSortDescriptor(key: "keyword", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil)
        }
        else{
            fetchedResultsController = nil
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MentionPopularityTableViewCell", forIndexPath: indexPath)
        
        if let men = fetchedResultsController?.objectAtIndexPath(indexPath) as? Mention {
            var mentionText: String?
            var mentionCount: NSNumber?
            men.managedObjectContext?.performBlockAndWait({ 
                mentionText = men.keyword
                mentionCount = men.count
            })
            cell.textLabel?.text = mentionText
            cell.detailTextLabel?.text =
                String(mentionCount!.intValue) + (mentionCount?.intValue == 1 ? " Mention" : " Mentions")
        }
        
        return cell
    }
}