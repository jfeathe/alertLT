//
//  BusStop.swift
//  alertLT
//
//  Created by Ryan Zegray on 2016-08-22.
//  Copyright © 2016 Ryan Zegray. All rights reserved.
//

import Foundation
import CoreData


class BusStop: NSManagedObject {
    
    /// Takes a stop that has been found on the WebWatch Website and adds it to the database
    class func addStopToDatabase(stop: WebWatchStop, inManagedObjectContex context: NSManagedObjectContext) -> BusStop? {
        
        //Fetch Request to see if the stop has already be added to the database
        let existingStopRequest = NSFetchRequest(entityName: "BusStop")
        existingStopRequest.predicate = NSPredicate(format: "number = %@", NSNumber(integer: stop.number))
        
        //If the stop already exists in the database return it
        if let existingStop = (try? context.executeFetchRequest(existingStopRequest))?.first as? BusStop {
            return existingStop
        //otherwise insert a new stop into the database and return the new stop
        } else if let newStop = NSEntityDescription.insertNewObjectForEntityForName("BusStop", inManagedObjectContext: context) as? BusStop {
            newStop.actualName = stop.name
            newStop.number = stop.number
            return newStop
        }
        
        return nil
    }

}
