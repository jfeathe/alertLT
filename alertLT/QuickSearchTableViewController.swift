//
//  QuickSearchTableViewController.swift
//  alertLT
//
//  Created by Ryan Zegray on 2016-08-31.
//  Copyright © 2016 Ryan Zegray. All rights reserved.
//

import UIKit
import CoreData

class QuickSearchTableViewController: FetchedResultsTableViewController, UISearchBarDelegate {

    enum Constants {
        static let ShowArrivalTimesSegue = "QSArrivalTimesSegue"
        static let QuickSearchCell = "QuickSearchCell"
    }
    
    // MARK: Model
    var managedObjectContex: NSManagedObjectContext? = FavoritesTableViewController.managedObjectContex
    
    // MARK: UI Elements
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
    
    // MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source
    
    private func initalizeFetchedResultsController() {
        initalizeFetchedResultsController(nil)
    }
    
    private func initalizeFetchedResultsController(searchBarString: String?) {
        let quickSearchRequest = NSFetchRequest(entityName: BusStop.entityName)
        quickSearchRequest.sortDescriptors = [NSSortDescriptor(key: "actualName", ascending: true)]
        
        if let searchString = searchBarString {
            quickSearchRequest.predicate = NSPredicate(format: "actualName CONTAINS[c] %@ OR number.stringValue CONTAINS[c] %@", searchString, searchString)
        }
        
        if let context = managedObjectContex {
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: quickSearchRequest,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            do {
                try fetchedResultsController?.performFetch()
                tableView.reloadData()
            } catch {
                fatalError("Failed to initialize FetchedResultsController: \(error)")
            }
        } else {
            fatalError("QuickSearchTableViewController does not have instance of managedObjectContext")
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.QuickSearchCell, forIndexPath: indexPath)
        configureCell(cell, forIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: UITableViewCell, forIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? BusInfoTableViewCell,
            let stop = fetchedResultsController?.objectAtIndexPath(indexPath) as? BusStop else {
                return
        }
        
        if let stopName = stop.actualName, stopNumber = stop.number {
            cell.primaryTextLabel.text = "\(stopNumber) - \(stopName)"
        }
        
        guard let unsortedRoutes = stop.routes?.allObjects as? [BusRoute] else {
            cell.secondaryTextLabel.text = "No routes found that stop at this stop"
            return
        }
        let routes = unsortedRoutes.sort { Int($0.number!) < Int($1.number!) }
        
        var listOfRoutesString = ""
        for (index, route) in routes.enumerate() {
            if index > 0 {
                listOfRoutesString += ", "
            }
            if let direction = route.direction, let number = route.number  {
                listOfRoutesString += "\(number)\(direction.substringToIndex(direction.startIndex.successor()))"
            }
        }
        cell.secondaryTextLabel.text = listOfRoutesString
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
    
    // MARK:  - Search Bar Delegate Methods
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count > 0 {
            initalizeFetchedResultsController(searchText)
        } else {
            initalizeFetchedResultsController(nil)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.ShowArrivalTimesSegue {
            if let arrivalTimesTVC = segue.destinationViewController.contentViewController as? ArrivalTimesTableViewController,
                sendingCell = sender as? BusInfoTableViewCell {
                if let sendingIndexPath = tableView.indexPathForCell(sendingCell) {
                    let selectedStop = fetchedResultsController?.objectAtIndexPath(sendingIndexPath) as? BusStop
                    arrivalTimesTVC.stop = selectedStop
                    arrivalTimesTVC.title = selectedStop?.actualName
                }
                
            }
        }
    }
}
