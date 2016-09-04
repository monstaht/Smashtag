//
//  Tweet+CoreDataProperties.swift
//  Smashtag
//
//  Created by Talha Baig on 8/20/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Tweet {

    @NSManaged var id: String?
    @NSManaged var text: String?
    @NSManaged var mentions: NSSet?

}
