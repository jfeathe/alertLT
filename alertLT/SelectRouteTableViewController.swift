//
//  SelectRouteTableViewController.swift
//  alertLT
//
//  Created by Ryan Zegray on 2016-08-24.
//  Copyright © 2016 Ryan Zegray. All rights reserved.
//

import UIKit
import CoreData

class SelectRouteTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    enum Constants {
        static let SelectRoutesCache = "selectRoutesCache"
        static let RouteCellIdentifier = "RouteCell"
    }
    
    //Outlets and UIElements
    @IBOutlet private weak var cancelBarButton: UIBarButtonItem!
    
    // MARK: Model
    var managedObjectContex: NSManagedObjectContext?
    var fetchedResultsController: NSFetchedResultsController?
    
    // MARK View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initalizeFetchedResultsController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    private func initalizeFetchedResultsController() {
        let routesRequest = NSFetchRequest(entityName: BusRoute.entityName)
        let nameSort = NSSortDescriptor(key: "number", ascending: true)
        let directionSort = NSSortDescriptor(key: "direction", ascending: true)
        routesRequest.sortDescriptors = [nameSort, directionSort]
        if let context = managedObjectContex {
            fetchedResultsController = NSFetchedResultsController(fetchRequest: routesRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: Constants.SelectRoutesCache)
            do {
                try fetchedResultsController?.performFetch()
            } catch {
                fatalError("Failed to initialize FetchedResultsController: \(error)")
            }
        } else {
            fatalError("SelectRouteTVC does not have instance of managedObjectContext")
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.RouteCellIdentifier, forIndexPath: indexPath)
        configureCell(cell, forIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: UITableViewCell, forIndexPath indexPath: NSIndexPath) {
        
        if let cell = cell as? SelectRouteTableViewCell,
            let route = fetchedResultsController?.objectAtIndexPath(indexPath) as? BusRoute {
            cell.busRoute = route
        }
    }
    
    // MARK - Fetched Results Controller Delegate Methods
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Move:
            break
        case .Update:
            break
        }
    }
    
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
