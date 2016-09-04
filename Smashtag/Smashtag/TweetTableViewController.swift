
//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by CS193p Instructor.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import Twitter
import CoreData

class TweetTableViewController: UITableViewController, UITextFieldDelegate
{
    // MARK: Model

    // holds the array which has the recent searches
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var context: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var tweets = [Array<Twitter.Tweet>]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var searchText: String? {
        didSet {
            setUserDefaults()
            tweets.removeAll()
            lastTwitterRequest = nil
            searchForTweets()
            title = searchText
        }
    }
    
    // MARK: Setting Recent Searches to User Defaults
    
    private func setUserDefaults(){
        if searchText != nil {
            if var defaultsRecentSearches = defaults.objectForKey("Recent Searches") as? [NSString] {
                //deletes previous occurence and adds new one to end of array
                if defaultsRecentSearches.contains(searchText!.lowercaseString){
                    defaultsRecentSearches = defaultsRecentSearches.filter() {$0 != searchText!.lowercaseString}
                    defaultsRecentSearches.append(searchText!.lowercaseString)
                }
                else{
                    defaultsRecentSearches.append(searchText!.lowercaseString)
                }
                defaults.setObject(defaultsRecentSearches, forKey: "Recent Searches")
            }
            // if this is a completely new application it starts here
            else{
                var recentSearches =  [NSString]()
                recentSearches.append(searchText!.lowercaseString)
                defaults.setObject(recentSearches, forKey: "Recent Searches")
            }
        }
    }
    
    // MARK: Fetching Tweets
    
    private var twitterRequest: Twitter.Request? {
        if lastTwitterRequest == nil {
            if let query = searchText where !query.isEmpty {
                return Twitter.Request(search: query + " -filter:retweets", count: 100)
            }
        }
        return lastTwitterRequest?.requestForNewer
    }
    
    private var lastTwitterRequest: Twitter.Request?

    private func searchForTweets()
    {
        if let request = twitterRequest {
            lastTwitterRequest = request
            request.fetchTweets { [weak weakSelf = self] newTweets in
                dispatch_async(dispatch_get_main_queue()) {
                    if request == weakSelf?.lastTwitterRequest {
                        if !newTweets.isEmpty {
                            weakSelf?.tweets.insert(newTweets, atIndex: 0)
                            weakSelf?.updateDatabase(newTweets)
                            weakSelf?.printDatabaseStatistics()
                        }
                    }
                    weakSelf?.refreshControl?.endRefreshing()
                }
            }
        } else {
            self.refreshControl?.endRefreshing()
        }
    }
    
    private func updateDatabase(tweets: [Twitter.Tweet]) {
        context.performBlock(){
            for twitterInfo in tweets {
                Tweet.tweetWithTwitterInfoAndSearchText(twitterInfo, andSearchText: self.searchText!, inContext: self.context)
            }
            do {
                try self.context.save()
            } catch let error {
                print("Core Data Error: \(error)")
            }
        }
    }
    
    private func printDatabaseStatistics() {
            context.performBlock(){
                let tweetResults = self.context.countForFetchRequest(NSFetchRequest(entityName: "Tweet"), error: nil)
                print("\(tweetResults) Tweets")
                let mentionResults = self.context.countForFetchRequest(NSFetchRequest(entityName: "Mention"), error: nil)
                print("\(mentionResults) Mentions")
        }
    }
        
    @IBAction func refresh(sender: UIRefreshControl) {
        searchForTweets()
    }
    
    // MARK: UITableViewDataSource

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(tweets.count - section)"
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TweetCellIdentifier, forIndexPath: indexPath)
        let tweet = tweets[indexPath.section][indexPath.row]
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(Storyboard.TweetSegueIdentifier, sender: tableView.cellForRowAtIndexPath(indexPath))
    }
    
    // MARK: Constants
    
    private struct Storyboard {
        static let TweetCellIdentifier = "Tweet"
        static let TweetSegueIdentifier = "Tweet Selected"
    }
    
    // MARK: Outlets

    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
    
    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchText = "#" + textField.text!
        return true
    }
    
    // MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        title = "Search"
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let tweetcell = sender as? TweetTableViewCell{
            if segue.identifier == Storyboard.TweetSegueIdentifier {
                if let destinationvc = segue.destinationViewController as? TweetMediaItemsViewController {
                    destinationvc.tweet = tweetcell.tweet
                    destinationvc.hashtagsColor = tweetcell.hashtagsColor
                    destinationvc.urlsColor = tweetcell.urlsColor
                    destinationvc.userMentionsColor = tweetcell.userMentionsColor
                }
            }
        }
    }
}
