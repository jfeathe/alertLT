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
    
    // MARK: Model
    var route: BusRoute?
    var managedObjectContex: NSManagedObjectContext?
    
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
    
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
    
    
    // MARK: - Search Bar Delegate Methods
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count > 0 {
            initalizeFetchedResultsController(searchText)
        } else {
            initalizeFetchedResultsController(nil)
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
