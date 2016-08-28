//
//  BusRoute+CoreDataProperties.swift
//  alertLT
//
//  Created by Ryan Zegray on 2016-08-28.
//  Copyright © 2016 Ryan Zegray. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension BusRoute {

    @NSManaged var direction: String?
    @NSManaged var hasStopsData: NSNumber?
    @NSManaged var name: String?
    @NSManaged var number: NSNumber?
    @NSManaged var stops: NSSet?

}
