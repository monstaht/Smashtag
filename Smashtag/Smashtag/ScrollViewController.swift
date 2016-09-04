//
//  ScrollViewController.swift
//  Smashtag
//
//  Created by Talha Baig on 7/20/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import Twitter

class ScrollViewController: UIViewController, UIScrollViewDelegate {

    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet{
            scrollView.contentSize = scrollView.frame.size
            scrollView.delegate = self
        }
    }

    private var imageView = UIImageView()
    
    private var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            imageView.contentMode = .ScaleAspectFill
            setScrollView()
        }
    }
    
    private func setScrollView(){
        scrollView.contentSize = imageView.bounds.size
        scrollView.delegate = self
        var minimumZoomScale = min(self.view.bounds.width / self.image!.size.width, self.view.bounds.height / self.image!.size.height)
        if minimumZoomScale > 1 {
            minimumZoomScale = 1
        }
        scrollView.minimumZoomScale = minimumZoomScale
        scrollView.maximumZoomScale = 1.0
        scrollView.zoomScale = minimumZoomScale
    }

    var mediaItem: Twitter.MediaItem? {
        didSet{
            if view.window != nil {
                fetchImage()
            }
        }
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0)
        self.scrollView.contentInset = UIEdgeInsetsMake(offsetY, offsetX, 0, 0)
        
        if !itWasATap {
            scrollView.backgroundColor = UIColor.blackColor()
            navigationController?.navigationBarHidden = true
            tabBarController?.tabBar.hidden = true
            itWasATap = false
        }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    private func fetchImage() {
        if let media = mediaItem {
            let url = media.url
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                let contentsOfUrl = NSData(contentsOfURL: url)
                dispatch_async(dispatch_get_main_queue()) {
                    if url == self.mediaItem!.url {
                        if let imageData = contentsOfUrl {
                            self.image = UIImage(data: imageData)!
                        }
                    }
                }
            }
        }
    }
    
    // Mark: View Controller Lifecycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil {
            fetchImage()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ScrollViewController.tap(_:))))
    }
    
    
    var itWasATap = true //makes sure that if its a tap then the scrollViewDidZoom will act accordingly
    
    func tap(recognizer: UITapGestureRecognizer){
        itWasATap = true
        recognizer.numberOfTapsRequired = 1
        switch recognizer.state {
        case .Ended:
            if let navcon = navigationController{
                if let tabcon = tabBarController {
                    if navcon.navigationBar.hidden {
                        scrollView.backgroundColor = UIColor.whiteColor()
                        navcon.navigationBar.hidden = false
                        tabcon.tabBar.hidden = false
                    }
                    else{
                        scrollView.backgroundColor = UIColor.blackColor()
                        navcon.navigationBar.hidden = true
                        tabcon.tabBar.hidden = true
                    }
                }
            }
        default:
            break
        }
    }

    //when the orientation changes
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if image != nil {
            image = imageView.image
        }
        scrollViewDidZoom(scrollView)
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
