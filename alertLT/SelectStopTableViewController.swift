//
//  SelectStopTableViewController.swift
//  alertLT
//
//  Created by Ryan Zegray on 2016-08-26.
//  Copyright © 2016 Ryan Zegray. All rights reserved.
//

import UIKit
import CoreData

class SelectStopTableViewController: FetchedResultsTableViewController {
    
    // MARK: Model
    var route: BusRoute?
    var managedObjectContex: NSManagedObjectContext?
    
    enum Constants {
        static let StopCellIdentifier = "StopCell"
        static let CustomizeFavoriteRouteSegue = "CustomizeFavoriteRouteSegue"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initalizeFetchedResultsController()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    private func initalizeFetchedResultsController() {
        let stopsRequest = NSFetchRequest(entityName: BusStop.entityName)
        stopsRequest.predicate = NSPredicate(format: "ANY routes == %@", route!)
        stopsRequest.sortDescriptors = [NSSortDescriptor(key: "actualName", ascending: true)]
        if let context = managedObjectContex {
            fetchedResultsController = NSFetchedResultsController(fetchRequest: stopsRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            do {
                try fetchedResultsController?.performFetch()
            } catch {
                fatalError("Failed to initialize FetchedResultsController: \(error)")
            }
        } else {
            fatalError("SelectRouteTVC does not have instance of managedObjectContext")
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.StopCellIdentifier, forIndexPath: indexPath)
        configureCell(cell, forIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: UITableViewCell, forIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? BusInfoTableViewCell,
            let stop = fetchedResultsController?.objectAtIndexPath(indexPath) as? BusStop else {
            return
        }
        
        if let stopName = stop.actualName, stopNumber = stop.number {
            cell.primaryTextLabel.text = stopName
            cell.secondaryTextLabel.text = "Stop: \(stopNumber)"
        }
    }
    
    // MARK - Fetched Results Controller Delegate Methods
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            configureCell(self.tableView.cellForRowAtIndexPath(indexPath!)!, forIndexPath: indexPath!)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        }
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == Constants.CustomizeFavoriteRouteSegue {
            if let desinationVC = segue.destinationViewController.contentViewController as? AddFavoriteStopViewController,
            sendingCell = sender as? BusInfoTableViewCell{
                desinationVC.route = route
                if let sendingIndexPath = tableView.indexPathForCell(sendingCell) {
                    desinationVC.stop = fetchedResultsController?.objectAtIndexPath(sendingIndexPath) as? BusStop
                }
            }
        }
    }

}
