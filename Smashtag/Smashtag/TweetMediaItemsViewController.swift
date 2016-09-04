//
//  TweetMediaItemsViewController.swift
//  Smashtag
//
//  Created by Talha Baig on 7/14/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import Twitter

class TweetMediaItemsViewController: UITableViewController {
    
    //main data holder of the TableView
    var tweet: Twitter.Tweet? = nil {
        didSet {
            updateData()
            tableView.reloadData()
        }
    }
    
    // controls the colors of the sections and whether they are consistent
    @IBInspectable var colorIsConsistentWithParent =  true
    var userMentionsColor: UIColor? = nil
    var hashtagsColor: UIColor? = nil
    var urlsColor: UIColor? = nil
    
    
    //holds all the stuff into a nice and neat array
    private var tableData: [MentionAndMediaHolder] = []
    
    //transition between having everything in tableData as MentionAndMediaHolder type
    private var dataDictionary: [String:[AnyObject]] = [:]
    
    private struct MentionAndMediaHolder {
        private var typeOfItem: String
        private var tweetData: [AnyObject]
    }

    private func updateData() {
        updateDataDictionary()
        for (key, value) in dataDictionary {
            tableData.append(MentionAndMediaHolder(typeOfItem: key, tweetData: value))
        }
    }
    
    private func updateDataDictionary() {
        if let tweet = tweet {
            if tweet.media.count != 0 {
                dataDictionary["Images"] = tweet.media
            }
            if tweet.urls.count != 0 {
                dataDictionary["Urls"] = tweet.urls
            }
            if tweet.userMentions.count != 0 {
                dataDictionary["User Mentions"] = tweet.userMentions
            }
            if tweet.hashtags.count != 0 {
                dataDictionary["Hashtags"] = tweet.hashtags
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return tableData.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tableData[section].tweetData.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Configure the cell based on whether the TweetData on the indexPath is a media or mention array
        var cell = UITableViewCell()
        let sectionTitle = tableData[indexPath.section].typeOfItem
        switch sectionTitle {
            case "Urls", "User Mentions", "Hashtags":
                cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.mentionTableCellIdentifier, forIndexPath: indexPath)
                keepColorConsistentWithParentViewController(colorIsConsistentWithParent, indexPath: indexPath, cell: cell)
                cell.textLabel?.text = dataDictionary[sectionTitle]![indexPath.row].keyword
            case "Images":
                cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.imageTableCellIdentifier, forIndexPath: indexPath)
                if let imageCell = cell as? ImageMediaViewCell {
                    imageCell.mediaItem = dataDictionary[sectionTitle]![indexPath.row] as? MediaItem
            }
            default:
                break
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableData[section].typeOfItem
        
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let sectionTitle = tableData[indexPath.section].typeOfItem
        switch sectionTitle {
            //case "Images":
              //  performSegueWithIdentifier(Storyboard.segueToScrollViewIndentifier, sender: self)
            case "Urls":
                let mentionType = dataDictionary[sectionTitle]![indexPath.row]
                if let url = NSURL(string: mentionType.keyword) {
                    UIApplication.sharedApplication().openURL(url)
                }
            default:
                break
            }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let sectionTitle = tableData[indexPath.section].typeOfItem
        switch sectionTitle {
            case "Images":
                if let picture = dataDictionary[sectionTitle]![indexPath.row] as? MediaItem {
                    return  view.frame.width / CGFloat(picture.aspectRatio)
                }
            default:
                break
            }
        return UITableViewAutomaticDimension
    }

    private func keepColorConsistentWithParentViewController(yesToColor: Bool, indexPath: NSIndexPath, cell: UITableViewCell){
        if yesToColor {
            switch self.tableData[indexPath.section].typeOfItem {
            case "Urls":
                cell.textLabel?.textColor = urlsColor
            case "Hashtags":
                cell.textLabel?.textColor = hashtagsColor
            case "User Mentions":
                cell.textLabel?.textColor = userMentionsColor
            default:
                break
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let destinationvc = segue.destinationViewController as? ScrollViewController {
            if let imageCell = sender as? ImageMediaViewCell {
                destinationvc.mediaItem = imageCell.mediaItem
            }
        }
    }
    
    private struct Storyboard {
        private static let imageTableCellIdentifier = "Media Item Displayer"
        private static let mentionTableCellIdentifier = "Mention Item Displayer"
        private static let segueToScrollViewIndentifier = "To Scroll View"
    }
}

