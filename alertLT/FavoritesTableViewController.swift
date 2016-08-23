//
//  FavoritesTableViewController.swift
//  alertLT
//
//  Created by Ryan Zegray on 2016-08-22.
//  Copyright © 2016 Ryan Zegray. All rights reserved.
//

import UIKit
import CoreData

class FavoritesTableViewController: UITableViewController {
    
    // MARK: Model
    
    var managedObjectContex: NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    
    var busRoutes = [
        WebWatchRoute(name: "Wellington Road", number: 13),
        WebWatchRoute(name: "Sarnia", number: 6),
        WebWatchRoute(name: "London Road", number: 9)

    ]
    var exampleDirection = WebWatchDirection.Northbound
    var busStops = [
        13: [ WebWatchStop(name: "Stop 12" ,number: 12), WebWatchStop(name: "Stop 8" ,number: 8), WebWatchStop(name: "Stop 19" ,number: 19)],
        6: [],
        9: [ WebWatchStop(name: "Stop 8" ,number: 8),  WebWatchStop(name: "Stop 99" ,number: 99) ]
    ]
    
    func updateDatabase() {
        managedObjectContex?.performBlock {

            for routeToAdd in self.busRoutes {
                _ = BusRoute.addRouteToDatabase(routeToAdd, withDirection: self.exampleDirection, withStops: self.busStops[routeToAdd.number]!, inManagedObjectContext: self.managedObjectContex!)
            }
            do {
                try self.managedObjectContex?.save()
            } catch let error {
                // TODO: Handel Possible saving error
                print("Core Data Error: \(error)")
            }
            
        }
    }
    
    private func printDatabaseStatistics() {
        managedObjectContex?.performBlock {
            if let results = try? self.managedObjectContex!.executeFetchRequest(NSFetchRequest(entityName: "BusRoute")) {
                for result in results {
                    if let route = result as? BusRoute {
                        print(route.name! + " - "+route.direction!)
                        for stop in route.stops?.allObjects as! [BusStop] {
                            print(stop.actualName!)
                        }
                        print("------------------")
                    }
                }
            }
        }
    }
    
    // MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        updateDatabase()
        printDatabaseStatistics()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
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

}
