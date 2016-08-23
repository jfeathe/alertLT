//
//  BusStop+CoreDataProperties.swift
//  alertLT
//
//  Created by Ryan Zegray on 2016-08-22.
//  Copyright © 2016 Ryan Zegray. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension BusStop {

    @NSManaged var actualName: String?
    @NSManaged var number: NSNumber?
    @NSManaged var customName: String?
    @NSManaged var favorited: NSNumber?
    @NSManaged var routes: NSSet?

}
