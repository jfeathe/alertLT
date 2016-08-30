//
//  BusRoute.swift
//  alertLT
//
//  Created by Ryan Zegray on 2016-08-22.
//  Copyright © 2016 Ryan Zegray. All rights reserved.
//

import Foundation
import CoreData


class BusRoute: NSManagedObject {
    
    //Manually Added Core Data accessor methods which cannot be automatically generated in swift
    @NSManaged func addStopsObject(value: BusStop)
    @NSManaged func removeStopsObject(value: BusStop)
    @NSManaged func addStops(value: Set<BusStop>)
    @NSManaged func removeStops(value: Set<BusStop>)
    
    static let directionAsString = [
        WebWatchDirection.Northbound : "Northbound",
        WebWatchDirection.Southbound : "Southbound",
        WebWatchDirection.Eastbound : "Eastbound",
        WebWatchDirection.Westbound : "Westbound"
    ]
    
    static let entityName = "BusRoute"
    
    /// Takes a route that has been found on the WebWatch Website and adds it to the database
    class func addRouteToDatabase(foundRoute: WebWatchRoute, withDirection foundDirection: WebWatchDirection, withStops foundStops: [WebWatchStop]?, inManagedObjectContext context: NSManagedObjectContext) -> BusRoute? {
        
        //Fetch Request to see if the route with a specific direction already exists in the database
        let existingRouteRequest = NSFetchRequest(entityName: "BusRoute")
        existingRouteRequest.predicate = NSPredicate(format: "number = %@ && direction = %@", NSNumber(integer: foundRoute.number), directionAsString[foundDirection]!)
        
        //if the route in that direction already exists in the database make sure that none of the stops have changed
        if let existingRoute = (try? context.executeFetchRequest(existingRouteRequest))?.first as? BusRoute {
            
            if let stops = foundStops {
                updateStopsInRoute(existingRoute, withFoundStops: stops, context:  context)
            }
            
            return existingRoute
        }
            
            //Otherwise we need add the route into the database
        else if let newRoute = NSEntityDescription.insertNewObjectForEntityForName("BusRoute", inManagedObjectContext: context) as? BusRoute {
            newRoute.name = foundRoute.name
            newRoute.number = foundRoute.number
            newRoute.direction = directionAsString[foundDirection]!
            
            if let stops = foundStops where stops.count > 0 {
                newRoute.hasStopsData = true
                for stop in stops {
                    if let databaseStop = BusStop.addStopToDatabase(stop, inManagedObjectContex: context) {
                        newRoute.addStopsObject(databaseStop)
                    }
                }
            } else {
                newRoute.hasStopsData = false
            }
            
            return newRoute
        }
        return nil
    }
    
    
    // FIXME: Try to find a more efficent way of checking for already existing stops
    
    /// Takes an already existing BusRoute in the database and updates it with any changes its stops
    private class func updateStopsInRoute(route: BusRoute, withFoundStops foundStops:  [WebWatchStop], context: NSManagedObjectContext) {
        
        guard let existingStops = route.stops as? Set<BusStop> else {
            return
        }
        
        //Check to see if any stops have been removed
        for existingStop in existingStops {
            
            var alreadyExistingStopStillExists = false
            
            for foundStop in foundStops {
                if existingStop.number == foundStop.number {
                    alreadyExistingStopStillExists = true
                }
            }
            
            if !alreadyExistingStopStillExists {
                
                route.removeStopsObject(existingStop)
                
                if route.stops?.count == 0 {
                    context.deleteObject(route)
                }
            }
        }
        //Check to see if any stops need to be added
        for foundStop in foundStops {
            var doesNotExistInExistingStops = true
            for existingStop in existingStops {
                if existingStop.number == foundStop.number {
                    doesNotExistInExistingStops = false
                }
            }
            
            if doesNotExistInExistingStops {
                if let databaseStop = BusStop.addStopToDatabase(foundStop, inManagedObjectContex: context) {
                    route.addStopsObject(databaseStop)
                }
            }
        }
    }
    
    func asWebWatchRouteAndDirection() -> (route: WebWatchRoute, direction: WebWatchDirection)? {
        guard let name = self.name, number = self.number, direction = self.direction else {
            return nil
        }
        
        let route = WebWatchRoute(name: name, number: Int(number))
        
        switch direction {
        case "Northbound" : return (route, WebWatchDirection.Northbound)
        case "Southbound" : return (route, WebWatchDirection.Southbound)
        case "Eastbound" : return (route, WebWatchDirection.Eastbound)
        case "Westbound" : return (route, WebWatchDirection.Westbound)
        default : return nil
        }
    }
}

