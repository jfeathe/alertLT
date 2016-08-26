//
//  SelectRouteTableViewController.swift
//  alertLT
//
//  Created by Ryan Zegray on 2016-08-24.
//  Copyright © 2016 Ryan Zegray. All rights reserved.
//

import UIKit
import CoreData

class SelectRouteTableViewController: UITableViewController {
    
    //Outlets and UI Elements
    
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    
    private var loadingDataSpinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    private var loadingDataLable:  UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.text = "Downloading Route Information \n This may take a moment."
        label.numberOfLines = 2
        label.textAlignment = .Center
        return label
    }()
    
    // MARK: Model
    
    var managedObjectContex: NSManagedObjectContext?
    private let defaults = NSUserDefaults.standardUserDefaults()
    private let busInfoScrapper = WebWatchScrapper()
    
    // MARK: Database updating methods
    
    func databaseShouldBeUpdated() -> Bool {
        if let lastUpdatedDate = (defaults.objectForKey(Constants.dateLastUpdatedKey) as? NSDate) {
            
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
    
    func updateDatabase() {
        
        displayLoadingInfoMessage()
        //Go to a different queue to load data from the webwatch website
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak weakSelf = self] in
            do {
                /////------ Try Placing all of this code in the webScrapper class except for the defaults
                if let routes = try weakSelf?.busInfoScrapper.fetchListOfRoutes() {
                    for route in routes {
                        if let direcetions = try weakSelf?.busInfoScrapper.fetchDirectionsForRoute(route) {
                            let firstDirectionStops = try weakSelf?.busInfoScrapper.fetchListOfStopsForRoute(route, forDirection: direcetions.firstDirection)
                            let secondDirectionStops = try weakSelf?.busInfoScrapper.fetchListOfStopsForRoute(route, forDirection: direcetions.secondDirection)
                            
                            weakSelf?.managedObjectContex?.performBlockAndWait { [weak weakSelf = self] in
                                BusRoute.addRouteToDatabase(route, withDirection: direcetions.firstDirection, withStops: firstDirectionStops, inManagedObjectContext: weakSelf!.managedObjectContex!)
                                
                                BusRoute.addRouteToDatabase(route, withDirection: direcetions.secondDirection, withStops: secondDirectionStops, inManagedObjectContext: weakSelf!.managedObjectContex!)
                                _ = try? weakSelf?.managedObjectContex?.save()
                            }
                            weakSelf?.defaults.setObject(NSDate(), forKey: Constants.dateLastUpdatedKey)
                        }
                    }
                /////------
                }
            // TODO: Handel Errors
            } catch WebWatchError.CannotGetContentsOfURL {
                print(1)
            } catch WebWatchError.InvalidURL {
                print(2)
            } catch {
                print(3)
            }
            //Go back to main queue and update UI
            dispatch_async(dispatch_get_main_queue()) {
                weakSelf?.hideLoadingInfo()
            }
        }
    }
    
    func displayLoadingInfoMessage() {
        self.navigationController?.view.addSubview(loadingDataLable)
        self.navigationController?.view.addSubview(loadingDataSpinner)
        loadingDataLable.hidden = false
        loadingDataSpinner.hidden = false
        loadingDataSpinner.startAnimating()
        cancelBarButton.enabled = false
        tableView?.scrollEnabled = false
    }
    
    private func hideLoadingInfo() {
        loadingDataLable.hidden = true
        loadingDataSpinner.hidden = true
        cancelBarButton.enabled = true
        tableView?.scrollEnabled = true
    }
    
    private func routesAreMissingInfo() -> [BusRoute]? {
        
        var routesMissingInfo: [BusRoute]?
        managedObjectContex?.performBlockAndWait { [weak weakSelf = self] in
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
    
//    private func printDatabaseContents() {
//        managedObjectContex?.performBlock {
//            if let results = try? self.managedObjectContex!.executeFetchRequest(NSFetchRequest(entityName: BusRoute.entityName)) {
//                for result in results {
//                    if let route = result as? BusRoute {
//                        print(route.name! + " - "+route.direction!)
//                        
//                        if let stops = route.stops?.allObjects as? [BusStop] {
//                            for stop in stops {
//                                print(stop.actualName!)
//                            }
//                        }
//                        print("------------------")
//                    }
//                }
//            }
//        }
//    }
    
    private func updateRoutes(routes: [BusRoute]) {
        //Only update routes if it has been at least 4 hours since the last update of any kind
    }
    
    // MARK View Controller Lifecycle

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        if let viewCenter = self.navigationController?.view.center {
            loadingDataSpinner.center = CGPoint(x: viewCenter.x, y: viewCenter.y - loadingDataLable.frame.height)
        }
        
        if let viewWidth = self.navigationController?.view.bounds.width,
            let viewCenter = self.navigationController?.view.center {
            loadingDataLable.frame = CGRect(x: 0, y: 0, width: viewWidth, height: 40)
            loadingDataLable.center = viewCenter
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if databaseShouldBeUpdated() {
            updateDatabase()
        } else if let routesMissingInfo = routesAreMissingInfo() {
            //updateRoutes(routesMissingInfo)
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    private enum Constants {
        static let dateLastUpdatedKey = "DateLastUpdated"
    }
}
