//
//  SelectRouteTableViewController.swift
//  alertLT
//
//  Created by Ryan Zegray on 2016-08-24.
//  Copyright © 2016 Ryan Zegray. All rights reserved.
//

import UIKit
import CoreData

class SelectRouteTableViewController: FetchedResultsTableViewController, UISearchBarDelegate {
    
    enum Constants {
        static let RouteCellIdentifier = "RouteCell"
        static let SelectStopSegueIdentifier = "SelectStopSegue"
    }
    
    // MARK: - Model
    var managedObjectContex: NSManagedObjectContext?
    
    // MARK: - UI Elements
    @IBOutlet private weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar! { didSet { searchBar.delegate = self } }
    
    // MARK: -  View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initalizeFetchedResultsController()
    }
    
    // MARK: - Table view data source
    private func initalizeFetchedResultsController() {
        initalizeFetchedResultsController(nil)
    }
    
    private func initalizeFetchedResultsController(searchBarString: String?) {
        
        let routesRequest = NSFetchRequest(entityName: BusRoute.entityName)
        
        let nameSort = NSSortDescriptor(key: "number", ascending: true)
        let directionSort = NSSortDescriptor(key: "direction", ascending: true)
        routesRequest.sortDescriptors = [nameSort, directionSort]
        
        if let searchString = searchBarString {
            routesRequest.predicate = NSPredicate(format: "name CONTAINS[c] %@ OR number.stringValue CONTAINS[c] %@", searchString, searchString)
        }
        
        if let context = managedObjectContex {
            fetchedResultsController = NSFetchedResultsController(fetchRequest: routesRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
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

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.RouteCellIdentifier, forIndexPath: indexPath)
        configureCell(cell, forIndexPath: indexPath)
        return cell
    }
    
    private func configureCell(cell: UITableViewCell, forIndexPath indexPath: NSIndexPath) {
        guard let busInfoCell = cell as? BusInfoTableViewCell, route = fetchedResultsController?.objectAtIndexPath(indexPath) as? BusRoute else {
            return
        }
        if let name = route.name, number = route.number, direction = route.direction {
            busInfoCell.primaryTextLabel.text = String(number)
            busInfoCell.secondaryTextLabel.text = "\(name) - \(direction.substringToIndex(direction.startIndex.successor()))"
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
        if segue.identifier == Constants.SelectStopSegueIdentifier {
            if let stopsTVC = segue.destinationViewController.contentViewController as? SelectStopTableViewController,
            sendingCell = sender as? BusInfoTableViewCell{
                stopsTVC.managedObjectContex = managedObjectContex
                stopsTVC.title = "Select a Stop"
                if let senderIndexPath = tableView.indexPathForCell((sendingCell)) {
                    stopsTVC.route = fetchedResultsController?.objectAtIndexPath(senderIndexPath) as? BusRoute
                }
            }
        }
    }
    
}
