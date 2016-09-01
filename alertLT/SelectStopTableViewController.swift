//
//  SelectStopTableViewController.swift
//  alertLT
//
//  Created by Ryan Zegray on 2016-08-26.
//  Copyright © 2016 Ryan Zegray. All rights reserved.
//

import UIKit
import CoreData

class SelectStopTableViewController: FetchedResultsTableViewController, UISearchBarDelegate {
    
    enum Constants {
        static let StopCellIdentifier = "StopCell"
        static let CustomizeFavoriteRouteSegue = "CustomizeFavoriteRouteSegue"
    }
    
    // MARK: - Model
    var route: BusRoute?
    var managedObjectContex: NSManagedObjectContext?
    
    // MARK: - UI Elements
    @IBOutlet weak var searchBar: UISearchBar! { didSet { searchBar.delegate = self } }
    
    // MARK: View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initalizeFetchedResultsController()
        checkForNoStopInfo()
    }

    // MARK: - Table view data source
    private func initalizeFetchedResultsController() {
        initalizeFetchedResultsController(nil)
    }
    
    private func initalizeFetchedResultsController(searchBarString: String?) {
        let stopsRequest = NSFetchRequest(entityName: BusStop.entityName)
        stopsRequest.sortDescriptors = [NSSortDescriptor(key: "actualName", ascending: true)]
        
        if let searchString = searchBarString {
            stopsRequest.predicate = NSPredicate(format: "ANY routes == %@ AND (actualName CONTAINS[c] %@ OR number.stringValue CONTAINS[c] %@)",route!,  searchString, searchString)
        } else {
            stopsRequest.predicate = NSPredicate(format: "ANY routes == %@", route!)
        }
        
        if let context = managedObjectContex {
            fetchedResultsController = NSFetchedResultsController(fetchRequest: stopsRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            do {
                try fetchedResultsController?.performFetch()
                tableView.reloadData()
            } catch {
                fatalError("Failed to initialize FetchedResultsController: \(error)")
            }
        } else {
            fatalError("SelectRouteTVC does not have instance of managedObjectContext")
        }
    }
    
    private func checkForNoStopInfo() {
        if fetchedResultsController?.sections?[0].numberOfObjects == 0 {
            let alert = UIAlertController(title: "No Stop Data for this Route",
                                          message: "This stop is currently not in service and we do not have any stop information saved. Please try again when this stop is in service.",
                                          preferredStyle: .Alert
            )
            alert.addAction(UIAlertAction(title: "Okay",
                style: .Default,
                handler: { [weak weakSelf = self] (alert: UIAlertAction) in  weakSelf?.navigationController?.popViewControllerAnimated(true)} )
            )
            presentViewController(alert, animated: true, completion: nil )
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.StopCellIdentifier, forIndexPath: indexPath)
        configureCell(cell, forIndexPath: indexPath)
        return cell
    }
    
    private func configureCell(cell: UITableViewCell, forIndexPath indexPath: NSIndexPath) {
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
    
    // MARK: - Search Bar Delegate Methods
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count > 0 {
            initalizeFetchedResultsController(searchText)
        } else {
            initalizeFetchedResultsController(nil)
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        endSearchBarEditing()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = nil
        initalizeFetchedResultsController(nil)
        endSearchBarEditing()
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        beginSearchBarEditing()
        return true
    }
    
    private func endSearchBarEditing() {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
    }
    
    private func beginSearchBarEditing() {
        searchBar.showsCancelButton = true
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        endSearchBarEditing()
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
