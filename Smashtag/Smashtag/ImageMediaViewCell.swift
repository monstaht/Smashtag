//
//  ImageMediaViewCell.swift
//  Smashtag
//
//  Created by Talha Baig on 7/20/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import Twitter

class ImageMediaViewCell: UITableViewCell {

    @IBOutlet var picture : UIImageView!
    
    var mediaItem: Twitter.MediaItem? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI(){
        picture.image = nil
        picture.contentMode = .ScaleAspectFit
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak weakSelf = self] in
            if let imageUrl = weakSelf?.mediaItem?.url {
                if let imageData = NSData(contentsOfURL: imageUrl){
                    dispatch_async(dispatch_get_main_queue()) {
                        weakSelf?.picture.image = UIImage(data: imageData)
                    }
                }
            }
        }
    }
}
