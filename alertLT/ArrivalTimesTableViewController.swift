//
//  ArrivalTimesTableViewController.swift
//  alertLT
//
//  Created by Ryan Zegray on 2016-08-29.
//  Copyright © 2016 Ryan Zegray. All rights reserved.
//

import UIKit

class ArrivalTimesTableViewController: UITableViewController {
    
    enum Constants {
        static let arrivalCell = "ArrivalTimeCell"
    }
    
    // Mark: Model
    
    var stop: BusStop? {
        didSet {
            fetchArrivalTimes()
        }
    }
    
    var arrivalTimesForEachRoute: [(String?, BusRoute)]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    private func fetchArrivalTimes() {
        
        var arrivals = [(String?, BusRoute)]()
        
        guard let stop = stop, unsortedRoutes = stop.routes?.allObjects as? [BusRoute] else {
            // TODO: throw somekind of error
            return
        }
        
        let routes = unsortedRoutes.sort { Int($0.number!) < Int($1.number!) }
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak weakSelf = self] in
            if let wwStop = stop.asWebWatchStop() {
                
                for route in routes {
                    
                    guard let (wwRoute, wwDirection) = route.asWebWatchRouteAndDirection() else {
                        // TODO: throw some kind of error
                        print("Error")
                        return
                    }
                    
                    do {
                        arrivals.append( (try WebWatchScrapper.fetchArrivalTimesForRoute(wwRoute, forDirection: wwDirection, forStop: wwStop), route))
                    } catch WebWatchError.CannotGetContentsOfURL {
                        print("Error")
                    } catch {
                        print("Error")
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                weakSelf?.arrivalTimesForEachRoute = arrivals
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.estimatedRowHeight = 100
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return arrivalTimesForEachRoute?.count ?? 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.arrivalCell, forIndexPath: indexPath)

        configureCell(cell, forIndexPath: indexPath)
        return cell
    }
 
    func configureCell(cell: UITableViewCell, forIndexPath indexPath: NSIndexPath) {
        guard let arrivalTimeCell = cell as? ArrivalTimeTableViewCell,
            arrivalTimesForEachRoute = arrivalTimesForEachRoute?[indexPath.row] else {
            return
        }
        
        let (estimatedArrivals, route) = arrivalTimesForEachRoute
        
        if let routeName = route.name, routeNumber = route.number, routeDirection = route.direction {
            arrivalTimeCell.routeNameLabel.text = "\(routeNumber) - \(routeName) \(routeDirection.substringToIndex(routeDirection.startIndex.successor()))"
        } else {
            arrivalTimeCell.routeNameLabel.text = "Error Unknown Route"
        }
        
        if let estimatedArrivals = estimatedArrivals {
            arrivalTimeCell.estimatedArrivalLabel.text = estimatedArrivals
            if let waitTime = calcWaitTime(estimatedArrivals) {
                arrivalTimeCell.waitTimeLabel.text = "\(waitTime) min"
                switch waitTime {
                case 0...5 : arrivalTimeCell.waitTimeLabel.textColor = UIColor.greenColor()
                case 6...15 : arrivalTimeCell.waitTimeLabel.textColor = UIColor.orangeColor()
                default : arrivalTimeCell.waitTimeLabel.textColor = UIColor.redColor()
                }
            } else {
                arrivalTimeCell.waitTimeLabel.text = ""
            }
        } else {
            arrivalTimeCell.estimatedArrivalLabel.text =  "No Arrival Times Found 😕"
            arrivalTimeCell.waitTimeLabel.text = ""
        }
    }
    
    func calcWaitTime(arrivalTimes: String) -> Int? {
        guard let calander = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian) else {
            return nil
        }
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "hh:mm"
        
        //The first word is the arrival time andthe rest is a description. So all we need is to take the first word
        let timeString = arrivalTimes.componentsSeparatedByString(" ")[0]
        
        let currentTime = NSDate()
        if let arrivalTime = formatter.dateFromString(timeString) {
            let currentComponents = calander.components([.Hour, .Minute], fromDate: currentTime)
            let arrivalComponents = calander.components([.Hour, .Minute], fromDate: arrivalTime)
            
            //adjust for 24 hour clock
            currentComponents.hour = currentComponents.hour > 12 ? currentComponents.hour - 12 : currentComponents.hour
            arrivalComponents.hour = arrivalComponents.hour == 0 ? 12 : arrivalComponents.hour
            
            let waitTimeInMin = (60 * (arrivalComponents.hour - currentComponents.hour)) + (arrivalComponents.minute - currentComponents.minute)
            return waitTimeInMin
            
        }
        return nil
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
