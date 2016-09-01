//
//  DatabaseUpdater.swift
//  alertLT
//
//  Created by Ryan Zegray on 2016-08-23.
//  Copyright © 2016 Ryan Zegray. All rights reserved.
//

import Foundation
import CoreData

/// Class that checks if the Core Data database needs to be updated and updates it
class DatabaseUpdater {
    
    private var managedObjectContex: NSManagedObjectContext?
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    private let stringToWebWatchDirection = [
        "Northbound" : WebWatchDirection.Northbound,
        "Southbound" : WebWatchDirection.Southbound,
        "Eastbound" : WebWatchDirection.Eastbound,
        "Westbound" : WebWatchDirection.Westbound
    ]
    
    private enum Constants {
        static let dateLastUpdatedKey = "DateLastUpdated"
    }
    
    var lastUpdatedDate: NSDate? {
        return defaults.objectForKey(Constants.dateLastUpdatedKey) as? NSDate
    }
    
    init(context: NSManagedObjectContext?) {
        self.managedObjectContex = context
    }
    
    /// Returns if the entire database should be updated
    func databaseShouldBeUpdated() -> Bool {
        // Update entire database if it hasnt been updated in 14 days
        return databaseIsOutOfDateBy(14, timeUnit: .Day)
    }
    
    /// Returns if only the routes missing info should be updated
    func missingRoutesShouldBeUpdated() -> Bool {
        // Update the missing stops if they havent been updated in 4 hours
        return databaseIsOutOfDateBy(4, timeUnit: .Hour)
    }
    
    ///Returns if the last database update is older then the given number of time units ago
    private func databaseIsOutOfDateBy(value: Int, timeUnit: NSCalendarUnit) -> Bool {
        if let lastUpdatedDate = (defaults.objectForKey(Constants.dateLastUpdatedKey) as? NSDate) {
            let calander = NSCalendar.currentCalendar()
            if let timeToCompareAgainst = calander.dateByAddingUnit(timeUnit, value: -value, toDate: NSDate(), options: [])  {
                if lastUpdatedDate == lastUpdatedDate.laterDate(timeToCompareAgainst) {
                    return false
                }
            }
        }
        return true
    }
    
    /// Returns and array of routes that are still missing information
    func routesMissingInfo() -> [BusRoute]? {
        var routesMissingInfo: [BusRoute]?
        managedObjectContex?.performBlockAndWait { [weak weakSelf = self] in
            let routesWithoutStopInfoRequest = NSFetchRequest(entityName: BusRoute.entityName)
            routesWithoutStopInfoRequest.predicate = NSPredicate(format: "hasStopsData == NO")
            routesWithoutStopInfoRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            
            let result =  try? weakSelf?.managedObjectContex!.executeFetchRequest(routesWithoutStopInfoRequest)
            if let routes = result as? [BusRoute] {
                routesMissingInfo = routes
            }
        }
        return routesMissingInfo
    }
    
    /// Updates the entire database of Bus Routes / Stop
    func updateEntireDatabase() throws {
        let routes = try WebWatchScrapper.fetchListOfRoutes()
        for route in routes {
            let directions = try WebWatchScrapper.fetchDirectionsForRoute(route)
            let firstDirectionStops = try WebWatchScrapper.fetchListOfStopsForRoute(route, forDirection: directions.firstDirection)
            let secondDirectionStops = try WebWatchScrapper.fetchListOfStopsForRoute(route, forDirection: directions.secondDirection)
            
            managedObjectContex?.performBlockAndWait { [weak weakSelf = self] in
                BusRoute.addRouteToDatabase(route,
                    withDirection: directions.firstDirection,
                    withStops: firstDirectionStops,
                    inManagedObjectContext: weakSelf!.managedObjectContex!
                )
                
                BusRoute.addRouteToDatabase(route,
                    withDirection: directions.secondDirection,
                    withStops: secondDirectionStops,
                    inManagedObjectContext: weakSelf!.managedObjectContex!
                )
                _ = try? weakSelf?.managedObjectContex?.save()
            }
        }
        defaults.setObject(NSDate(), forKey: Constants.dateLastUpdatedKey)
    }
    
    /// Updates only the given routes information
    func updateRoutes(routes: [BusRoute]) throws {
        for route in routes {
            if let name = route.name, number = route.number, directionString = route.direction {
                
                let wwRoute = WebWatchRoute(name: name, number: Int(number))
                if let wwDirection = stringToWebWatchDirection[directionString] {
                    let wwStops = try WebWatchScrapper.fetchListOfStopsForRoute(wwRoute, forDirection: wwDirection)
        
                    managedObjectContex?.performBlockAndWait { [weak weakSelf = self] in
                        BusRoute.addRouteToDatabase(wwRoute, withDirection: wwDirection, withStops: wwStops, inManagedObjectContext: weakSelf!.managedObjectContex!)
                    }
                }
            }
        }
        defaults.setObject(NSDate(), forKey: Constants.dateLastUpdatedKey)
    }
}





