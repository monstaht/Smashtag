//
//  RecentSearchesTableViewController.swift
//  Smashtag
//
//  Created by Talha Baig on 8/17/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

class RecentSearchesTableViewController: UITableViewController {


    // Model
    
    let defaults = NSUserDefaults.standardUserDefaults()
    let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var recentSearchesArray = [Array<NSString>](){
        didSet{
            tableView.reloadData()
        }
    }
    
    // View Controller Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        tabBarItem = UITabBarItem(title: "Recent Searches", image: nil, tag: 1)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let recentSearches = defaults.objectForKey("Recent Searches") as? [NSString] {
            recentSearchesArray.removeAll()
            recentSearchesArray.append(recentSearches.reverse())
        }
    }
    
    override func viewDidLoad() {
        title = "Recent Searches"
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return recentSearchesArray.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return recentSearchesArray[section].count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
        cell.textLabel?.text = recentSearchesArray[indexPath.section][indexPath.row] as String
        return cell
    }
    
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("im here")
        print(segue.destinationViewController)
        if let destinationvc = segue.destinationViewController as? MentionPopularityTableViewController {
            if let sendingCell = sender as? UITableViewCell {
                print("At prepare for segue")
                destinationvc.mention = sendingCell.textLabel?.text
                destinationvc.managedObjectContext = context
            }
        }
    }
    
    private struct Storyboard{
        static let tweetTableViewControllerSegue = "Tweet Table Segue"
    }

}
