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
    
    // TODO: Add Check for if on WIFI
    func databaseShouldBeUpdated() -> Bool {
        return lastDatabaseUpdateWasMoreThan(14, timeUnit: .Day)
    }
    
    func missingRoutesShouldBeUpdated() -> Bool {
        return lastDatabaseUpdateWasMoreThan(4, timeUnit: .Hour)
    }
    
    ///Returns if the last database update is older then the given number of time units ago
    private func lastDatabaseUpdateWasMoreThan(value: Int, timeUnit: NSCalendarUnit) -> Bool {
        if let lastUpdatedDate = (defaults.objectForKey(Constants.dateLastUpdatedKey) as? NSDate) {
            let calander = NSCalendar.currentCalendar()
            if let timeToCompareAgainst = calander.dateByAddingUnit(timeUnit, value: -value, toDate: NSDate(), options: [])  {
                if !(lastUpdatedDate == lastUpdatedDate.earlierDate(timeToCompareAgainst)) {
                    return false
                }
            }
        }
        return true
    }
    
    func routesMissingInfo() -> [BusRoute]? {
        
        var routesMissingInfo: [BusRoute]?
        managedObjectContex?.performBlockAndWait {
            [weak weakSelf = self] in
            let routesWithoutStopsRequest = NSFetchRequest(entityName: BusRoute.entityName)
            routesWithoutStopsRequest.predicate = NSPredicate(format: "hasStopsData == NO")
            routesWithoutStopsRequest.sortDescriptors =  [NSSortDescriptor(key: "name", ascending: true)]
            
            let result =  try? weakSelf?.managedObjectContex!.executeFetchRequest(routesWithoutStopsRequest)
            if let routes = result as? [BusRoute] {
                routesMissingInfo = routes
            }
        }
        return routesMissingInfo
    }
    
    func updateEntireDatabase() throws {
        let routes = try WebWatchScrapper.fetchListOfRoutes()
        for route in routes {
            let directions = try WebWatchScrapper.fetchDirectionsForRoute(route)
            
            let firstDirectionStops = try WebWatchScrapper.fetchListOfStopsForRoute(route, forDirection: directions.firstDirection)
            let secondDirectionStops = try WebWatchScrapper.fetchListOfStopsForRoute(route, forDirection: directions.secondDirection)
            
            managedObjectContex?.performBlockAndWait { [weak weakSelf = self] in
                BusRoute.addRouteToDatabase(route, withDirection: directions.firstDirection, withStops: firstDirectionStops, inManagedObjectContext: weakSelf!.managedObjectContex!)
                
                BusRoute.addRouteToDatabase(route, withDirection: directions.secondDirection, withStops: secondDirectionStops, inManagedObjectContext: weakSelf!.managedObjectContex!)
                _ = try? weakSelf?.managedObjectContex?.save()
            }
        }
        defaults.setObject(NSDate(), forKey: Constants.dateLastUpdatedKey)
    }
    
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
    
    func printDatabaseContents() {
        managedObjectContex?.performBlock {
                if let results = try? self.managedObjectContex!.executeFetchRequest(NSFetchRequest(entityName: BusRoute.entityName)) {
                for result in results {
                    if let route = result as? BusRoute {
                        print(route.name! + " - "+route.direction!)
                        if let stops = route.stops?.allObjects as? [BusStop] {
                            for stop in stops.sort( {  $0.actualName < $1.actualName} ) {
                                print(stop.actualName!)
                            }
                        }
                        print("-----------------------------")
                    }
                }
            }
        }
    }

}





