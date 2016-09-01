//
//  WebWatch.swift
//  alertLT
//
//  Created by Ryan Zegray on 2016-08-22.
//  Copyright © 2016 Ryan Zegray. All rights reserved.
//

import Foundation

struct WebWatchRoute {
    var name: String
    var number: Int
}

enum WebWatchDirection: Int {
    case Northbound = 2
    case Eastbound = 1
    case Southbound = 3
    case Westbound = 4
}

struct WebWatchStop {
    var name: String
    var number: Int
}

enum WebWatchError: ErrorType {
    case CannotGetContentsOfURL
    case InvalidURL
}

/// Class that has
class WebWatchScrapper {
    
    private struct WebWatchConstants {
        static let queryPrefix: String = "http://www.ltconline.ca/WebWatch/MobileAda.aspx?"
    }
    
    /// Returns a list of all avaliable LTC routes from the webwatch website.
    static func fetchListOfRoutes() throws -> [WebWatchRoute] {
        
        guard let routesURL = NSURL(string: WebWatchConstants.queryPrefix) else {
            throw WebWatchError.InvalidURL
        }
        do {
            let contentsOfURL = try String(contentsOfURL: routesURL)
            return scrapeRoutesFromWebWatchPage(contentsOfURL)
        } catch {
            throw WebWatchError.CannotGetContentsOfURL
        }
        
    }
    
    /// Parses the "Choose a route" WebWatch page and returns an array of all routes.
    private static func scrapeRoutesFromWebWatchPage(htmlPage: String) -> [WebWatchRoute] {
        
        var routes = [WebWatchRoute]()
        
        //if we seperate html page by <br> tags we get an array with all routes as their own element thanks to how the WebWatch page is organzied
        let seperations = htmlPage.componentsSeparatedByString("<br>")
        
        //but we also have extra junk seperations in the array that we do not need
        //so we need to check each seperation and see which ones contain routes
        for var seperation in seperations {
            //if the seperation has this prefix we know it must contain a route
            if seperation.hasPrefix("\r\n<a href=\"MobileAda.aspx?r=") {
                //Trim the begining of the <a> html tag
                seperation.removePrefix("\r\n<a href=\"MobileAda.aspx?r=")
                //Trim the ending of the <a> html tag
                seperation.removeSuffix("</a>")
                //What we are left with is the routeNumber followed by the route name with "\>" in between
                //So if we we split the remaining bit of the seperation by that sequence of characters it gives us
                //the route number at index 0 and the route name at index 1
                var routeData = seperation.componentsSeparatedByString("\">")
                
                if let routeNumber = Int(routeData[0]) {
                    routes.append(WebWatchRoute(name: routeData[1], number: routeNumber))
                }
            }
        }
        return routes
    }
    
    /// Returns a tuple with both directions that a LTC route travels which is retrived from the webwatch website.
    static func fetchDirectionsForRoute(route: WebWatchRoute) throws -> (firstDirection: WebWatchDirection, secondDirection: WebWatchDirection) {
        
        let directionsURLString = "\(WebWatchConstants.queryPrefix)r=\(route.number)"
        guard let directionsURL = NSURL(string: directionsURLString) else {
            throw WebWatchError.InvalidURL
        }
        
        do {
            let contentsOfURL = try String(contentsOfURL: directionsURL)
            return try scrapeDirectionsFromWebWatchPage(contentsOfURL)
        } catch {
            throw WebWatchError.CannotGetContentsOfURL
        }
        
    }
    
    /// Parses the "Choose a direction" page and returns a tuple with both directions the bus can return.
    private static func scrapeDirectionsFromWebWatchPage(htmlPage: String) throws -> (firstDirection: WebWatchDirection, secondDirection: WebWatchDirection) {
        if htmlPage.containsString("NORTHBOUND") {
            //If the HTML page contains "NORTHNBOUND" then the route MUST be a North/South bus route
            return (WebWatchDirection.Northbound, WebWatchDirection.Southbound)
        } else {
            //Othewise the route MUST be a East/West route
            return (WebWatchDirection.Eastbound, WebWatchDirection.Westbound)
        }
        
    }
    
    
    /// Returns a Array of webwatch stops for the given route from the webwatch website.
    /// If the array is returned as nil it means that the route is not in service and we cannot get a list of stops.
    static func fetchListOfStopsForRoute(route: WebWatchRoute, forDirection direction: WebWatchDirection) throws -> [WebWatchStop]? {
        
        let stopsURLString = "\(WebWatchConstants.queryPrefix)r=\(route.number)&d=\(direction.rawValue)"
        guard let stopsURL = NSURL(string: stopsURLString) else {
            throw WebWatchError.InvalidURL
        }
        do {
            let contentsOfURL = try String(contentsOfURL: stopsURL)
            return scrapeStopsFromWebWatchPage(contentsOfURL, forRoute: route, forDirection: direction)
        } catch {
            throw WebWatchError.CannotGetContentsOfURL
        }
    }
    
    /// Parses the "Choose your stop" page and returns an array of all stops for a route and direction.
    /// If the array is returned as nil it means that the route is not in service and we cannot get a list of stops.
    private static func scrapeStopsFromWebWatchPage(htmlPage: String, forRoute route: WebWatchRoute, forDirection direction: WebWatchDirection) -> [WebWatchStop]? {
        
        var stops = [WebWatchStop]()
        //if we seperate html page by <br> tags we get an array with all stops as their own element thanks to how the WebWatch page is organzied
        let seperations = htmlPage.componentsSeparatedByString("<br>")
        //but we also have extra junk seperations in the array that we do not need
        //so we need to check each seperation and see which ones contain stops
        for var seperation in seperations {
            
            //if the seperation has this prefix we know it must contain a stop
            if seperation.hasPrefix("\r\n<a href=\"MobileAda.aspx?r=") {
                
                //Trim the begining of the <a> html tag
                seperation.removePrefix("\r\n<a href=\"MobileAda.aspx?r=")
                //Trim the ending of the <a> html tag
                seperation.removeSuffix("</a>")
                //What we are left with is the route, direction and stop followed by the stop name with "\>" in between
                //So if we we split the remaining bit of the seperation by that sequence of characters it gives us
                //the route, direction and stop as a string in index 0 and the stop name at index 1
                var values = seperation.componentsSeparatedByString("\">")
                var nameOfStop = values[1]
                nameOfStop.removeString("amp;")
                //If we take the length of the string that contains the route, direction and stop and take away the route and direction
                //we are left with the length of the stop number
                let numberOfDigitsInStopNumber = -(values[0].characters.count - "\(String(format: "%02d", route.number))&d=\(direction.rawValue)&s=".characters.count)
                //we can then use the length of the stop number to get ONLY the stop number our of the route, direction and stop string
                if let numOfStop = Int(values[0].substringWithRange(values[0].endIndex.advancedBy(numberOfDigitsInStopNumber)..<values[0].endIndex)) {
                    stops.append(WebWatchStop(name: nameOfStop, number: numOfStop))
                }
            }
        }
        return stops.count > 0 ? stops : nil
    }
    
    /// Returns a string that contains the arrival times avaliable for a given route and stop
    /// If the string returned is nil the stop is not in service
    static func fetchArrivalTimesForRoute(route: WebWatchRoute, forDirection direction: WebWatchDirection, forStop stop: WebWatchStop) throws -> String? {
        
        let arrivalTimesURLString = "\(WebWatchConstants.queryPrefix)r=\(route.number)&d=\(direction.rawValue)&s=\(stop.number)"
        guard let arrivalTimesURL = NSURL(string: arrivalTimesURLString) else {
            throw WebWatchError.InvalidURL
        }
        
        do {
            let contentsOfURL = try String(contentsOfURL: arrivalTimesURL)
            return scrapeArrivalTimesFromWebWatchPage(contentsOfURL)
        } catch {
            throw WebWatchError.CannotGetContentsOfURL
        }
    }
    
    /// Given an html page that contains the arrival times it puts them all into one string and returns it
    private static func scrapeArrivalTimesFromWebWatchPage(htmlPage: String) -> String? {
        
        
        ///if we seperate the html page by <br> tags we get an array with all arrival times as their own element
        let seperations = htmlPage.componentsSeparatedByString("<br>")
        //But we also have extra seperations in the array we do not need
        //so we need to check each seperation and see which ones contain arrival times
        var arrivalTimes = ""
        for seperation in seperations {
            //if the seperation contains "A.M" or "P.M" it must be an arrival time
            if seperation.containsString("A.M") || seperation.containsString("P.M") {
                var time = seperation
                time.removeExcessSpaces()
                time.removePrefix("\r\n")
                arrivalTimes = arrivalTimes + time + "\n"
            }
        }
        arrivalTimes.removeSuffix("\n")
        return arrivalTimes.characters.count > 0 ? arrivalTimes : nil
    }

}