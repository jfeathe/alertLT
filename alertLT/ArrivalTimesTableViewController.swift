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
    
    var stop: BusStop? { didSet { fetchArrivalTimes() } }
    var arrivalTimesForEachRoute: [(String?, BusRoute)]? { didSet { tableView.reloadData() } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        self.tableView?.estimatedRowHeight = 100
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.backgroundColor = UIColor.verylightGrayColor()
        self.refreshControl?.addTarget(self, action: #selector(ArrivalTimesTableViewController.fetchArrivalTimes), forControlEvents: .ValueChanged)
        
        let loadingLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        loadingLabel.text = "Fetching arrival times..."
        loadingLabel.textColor = UIColor.lightGrayColor()
        loadingLabel.textAlignment = .Center
        self.tableView.backgroundView = loadingLabel
    }
    
    @objc private func fetchArrivalTimes() {
        
        var arrivals = [(String?, BusRoute)]()
        guard let stop = stop, unsortedRoutes = stop.routes?.allObjects as? [BusRoute] else {
            return
        }
        let routes = unsortedRoutes.sort { Int($0.number!) < Int($1.number!) }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak weakSelf = self] in
            if let wwStop = stop.asWebWatchStop() {
                
                do {
                    for route in routes {
                        guard let (wwRoute, wwDirection) = route.asWebWatchRouteAndDirection() else {
                            return
                        }
                        
                        arrivals.append( (try WebWatchScrapper.fetchArrivalTimesForRoute(wwRoute, forDirection: wwDirection, forStop: wwStop), route))
                    }
                } catch WebWatchError.CannotGetContentsOfURL {
                    dispatch_async(dispatch_get_main_queue()) {
                        let alert = UIAlertController(title: "No Internet Connection",message: "Please check your connection and try again later", preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "Okay",
                            style: .Default,
                            handler: { [weak weakSelf = self] (alert: UIAlertAction) in  weakSelf?.navigationController?.popViewControllerAnimated(true)} )
                        )
                        weakSelf?.presentViewController(alert, animated: true, completion: nil )
                    }
                } catch {
                    dispatch_async(dispatch_get_main_queue()) {
                        let alert = UIAlertController(title: "An Error has occured", message: "Unable to get LTC data please try again later", preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "Okay",
                            style: .Default,
                            handler: { [weak weakSelf = self] (alert: UIAlertAction) in  weakSelf?.navigationController?.popViewControllerAnimated(true)} )
                        )
                        weakSelf?.presentViewController(alert, animated: true, completion: nil )
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                weakSelf?.arrivalTimesForEachRoute = arrivals
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "MMM d, h:mm a"
                weakSelf?.refreshControl?.attributedTitle = NSAttributedString(string: "Last Updated on \(dateFormatter.stringFromDate(NSDate()))")
                weakSelf?.refreshControl?.endRefreshing()
                weakSelf?.tableView.backgroundView = nil
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let numRows =  arrivalTimesForEachRoute?.count where numRows > 0{
            tableView.backgroundView = nil
            return numRows
        }
        return 0
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
            if let waitTime = calcWaitTimeUsing(estimatedArrivals) {
                arrivalTimeCell.waitTimeLabel.text = waitTime > 0 ? "\(waitTime) min" : "due"
                switch waitTime {
                case 0...5 : arrivalTimeCell.waitTimeLabel.textColor = UIColor.darkGreenColor()
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
    
    func calcWaitTimeUsing(arrivalTimes: String) -> Int? {
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
}
