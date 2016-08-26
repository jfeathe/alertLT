//
//  DatabaseUpdater.swift
//  alertLT
//
//  Created by Ryan Zegray on 2016-08-23.
//  Copyright © 2016 Ryan Zegray. All rights reserved.
//

import Foundation
import CoreData

class DatabaseUpdater {
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    private let scrapper = WebWatchScrapper()
    
    private var managedObjectContex: NSManagedObjectContext?
    
    init(contex: NSManagedObjectContext?) {
        managedObjectContex = contex
    }
    
    func updateDatabase() throws {
        if entireDatabaseUpdateRequired() {
            print("DB Updated Required")
            //updateEntireDatabaseFromWebWatch()
            print("Updated DB")
        } else if let arrayOfRoutesToUpdate = updateSpecificRoutesOnlyRequied() {
            print("Partial DB Update Required")
            print(arrayOfRoutesToUpdate.count)
            for routeToUpdate in arrayOfRoutesToUpdate {
                print(routeToUpdate.name! + " " + String(routeToUpdate.number!))
            }
        }
    }
    
    private func entireDatabaseUpdateRequired() -> Bool  {
        
        if let lastUpdatedDate = (defaults.objectForKey(DatabaseConstants.dateLastUpdatedKey) as? NSDate) {
            
            let calander = NSCalendar.currentCalendar()
            
            guard let twoWeeksAgo = calander.dateByAddingUnit(.Day, value: -14, toDate: NSDate(), options: []) else {
                return true
            }
            
            if lastUpdatedDate == lastUpdatedDate.earlierDate(twoWeeksAgo) {
                return true
            } else {
                return false
            }
            
        } else {
            return true
        }
    }
    
    private func updateSpecificRoutesOnlyRequied() -> [BusRoute]? {
        //Use predicate to find routes that have not gotten stop data yet
        let noStopsDataPredicate = NSPredicate(format: "hasStopsData == NO")
        
        let request = NSFetchRequest(entityName: "BusRoute")
        request.predicate = noStopsDataPredicate
        
        return  (try? managedObjectContex!.executeFetchRequest(request)) as? [BusRoute]
    }
    
    private func updateEntireDatabaseFromWebWatch() throws {
        defaults.setObject(NSDate(), forKey: DatabaseConstants.dateLastUpdatedKey)
        
//        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
//            
//        }
    }
    
    private func updateSpecifcRoutesFromWebWatch(routesToUpdate: [BusRoute]) {
        //then update them with webwatch data
    }
    
    
    private enum DatabaseConstants {
        static let dateLastUpdatedKey = "Date Database Last Updated"
    }
    
    
    private func printDatabaseContents() {
        managedObjectContex?.performBlock {
            if let results = try? self.managedObjectContex!.executeFetchRequest(NSFetchRequest(entityName: "BusRoute")) {
                for result in results {
                    if let route = result as? BusRoute {
                        print(route.name! + " - "+route.direction!)
                        
                        if let stops = route.stops?.allObjects as? [BusStop] {
                            for stop in stops {
                                print(stop.actualName!)
                            }
                        }
                        print("------------------")
                    }
                }
            }
        }
    }
}

//let scrapper = WebWatchScrapper()
//
//
//do {
//    let routes = try scrapper.fetchListOfRoutes()
//    
//    for route in routes {
//        let (firstDirection, secondDirection) = try scrapper.fetchDirectionsForRoute(route)
//        
//        if let firstDirectionStops = try scrapper.fetchListOfStopsForRoute(route, forDirection: firstDirection),
//            let secondDirectionStops = try scrapper.fetchListOfStopsForRoute(route, forDirection: secondDirection) {
//            
//            managedObjectContex?.performBlock {
//                BusRoute.addRouteToDatabase(route, withDirection: firstDirection, withStops: firstDirectionStops, inManagedObjectContext: self.managedObjectContex!)
//                BusRoute.addRouteToDatabase(route, withDirection: secondDirection, withStops: secondDirectionStops, inManagedObjectContext: self.managedObjectContex!)
//            }
//        }
//        
//    }
//    
//} catch WebWatchError.InvalidURL {
//    //TODO: Handel Errors
//} catch WebWatchError.CannotGetContentsOfURL {
//    
//} catch {
//    
//}
//
//







