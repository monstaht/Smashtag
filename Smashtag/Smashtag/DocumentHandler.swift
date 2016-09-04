//
//  DocumentHandler.swift
//  Smashtag
//
//  Created by Talha Baig on 8/19/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import CoreData

class DocumentHandler: UIManagedDocument {
    
    
    class func getManagedDocument() -> UIManagedDocument? {
        let fm = NSFileManager.defaultManager()
        var document: UIManagedDocument?
        if let docsdir = fm.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first {
            let url = docsdir.URLByAppendingPathComponent("Smashtag")
            document = UIManagedDocument(fileURL: url)
        }
        return document
    }
    
    class func useContextToPerformBlock(document: UIManagedDocument, inBlock block: (context: NSManagedObjectContext) -> () ) {
        objc_sync_enter(document)
        document.managedObjectContext.performBlock{
            if document.documentState == .Normal {
                block(context: document.managedObjectContext)
            }
            if document.documentState == .Closed {
                if let path = document.fileURL.path {
                    let fileExists = NSFileManager.defaultManager().fileExistsAtPath(path)
                    if fileExists {
                        document.openWithCompletionHandler(){ (success) in
                            block(context: document.managedObjectContext)
                        }
                    }
                    else {
                        document.saveToURL(document.fileURL, forSaveOperation: .ForCreating) { (success) in
                            block(context: document.managedObjectContext)
                        }
                    }
                }
            }
        }
        objc_sync_exit(document)
    }
}

