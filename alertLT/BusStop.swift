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
    
    static let entityName = "BusStop"
    
    /// Takes a stop that has been found on the WebWatch Website and adds it to the database
    class func addStopToDatabase(foundStop: WebWatchStop, inManagedObjectContex context: NSManagedObjectContext) -> BusStop? {
        
        //Fetch Request to see if the stop has already be added to the database
        let existingStopRequest = NSFetchRequest(entityName: "BusStop")
        existingStopRequest.predicate = NSPredicate(format: "number = %@", NSNumber(integer: foundStop.number))
        
        //If the stop already exists in the database return it
        if let existingStop = (try? context.executeFetchRequest(existingStopRequest))?.first as? BusStop {
            return existingStop
        //otherwise insert a new stop into the database and return the new stop
        } else if let newStop = NSEntityDescription.insertNewObjectForEntityForName("BusStop", inManagedObjectContext: context) as? BusStop {
            newStop.actualName = foundStop.name
            newStop.number = foundStop.number
            return newStop
        }
        
        return nil
    }
    
    /// Converts a BusStop to a WebWatch Stop object
    func asWebWatchStop() -> WebWatchStop? {
        guard let name = self.actualName, number = self.number else {
            return nil
        }
        return WebWatchStop(name: name, number: Int(number))
    }

}
