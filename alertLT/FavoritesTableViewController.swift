//
//  FavoritesTableViewController.swift
//  alertLT
//
//  Created by Ryan Zegray on 2016-08-22.
//  Copyright © 2016 Ryan Zegray. All rights reserved.
//

import UIKit
import CoreData


class FavoritesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    enum Constants {
        static let SelectRouteSegue = "SelectRouteSegue"
        static let FavoriteStopCell = "FavoriteStopCell"
    }
    
    //UI Elements for the Loading Data Message
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
    
    var managedObjectContex: NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    
    var fetchedResultsController: NSFetchedResultsController? {
        didSet {
            fetchedResultsController?.delegate = self
        }
    }
    
    // MARK: Updating Database Methods
    func showLoadingMessage() {
        self.navigationController?.view.addSubview(loadingDataLable)
        self.navigationController?.view.addSubview(loadingDataSpinner)
        loadingDataLable.hidden = false
        loadingDataSpinner.hidden = false
        loadingDataSpinner.startAnimating()
        tableView?.scrollEnabled = false
    }
    
    private func hideLoadingMessage() {
        loadingDataLable.hidden = true
        loadingDataSpinner.hidden = true
        tableView?.scrollEnabled = true
    }
    
    ///Updates the database using a DatabaseUpdater instance. Pass in an array of stops if you want to limit which routes are updated
    private func updateDatabaseUsing(dbUpdater: DatabaseUpdater, onlyUpdateRoutes routesToUpdate: [BusRoute]?) {
        showLoadingMessage()
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak weakSelf = self] in
            do {
                if let routes = routesToUpdate {
                    try dbUpdater.updateRoutes(routes)
                } else {
                    try dbUpdater.updateEntireDatabase()
                }
                // TODO: Handel Errors
            } catch WebWatchError.CannotGetContentsOfURL {
                print(1)
            } catch WebWatchError.InvalidURL {
                print(2)
            } catch {
                print(3)
            }
            dispatch_async(dispatch_get_main_queue()) {
                weakSelf?.hideLoadingMessage()
                dbUpdater.printDatabaseContents()
            }
        }
    }

    
    // MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        editButtonItem().tintColor = UIColor.whiteColor()
        initalizeFetchedResultsController()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let dbUpdater = DatabaseUpdater(context: managedObjectContex)
        if dbUpdater.databaseShouldBeUpdated() {
            updateDatabaseUsing(dbUpdater, onlyUpdateRoutes: nil)
        } else if let routesThatAreMissingInformation = dbUpdater.routesMissingInfo() where dbUpdater.missingRoutesShouldBeUpdated() {
            updateDatabaseUsing(dbUpdater, onlyUpdateRoutes: routesThatAreMissingInformation)
        }
        dbUpdater.printDatabaseContents()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let viewCenter = self.navigationController?.view.center {
            loadingDataSpinner.center = CGPoint(x: viewCenter.x, y: viewCenter.y - loadingDataLable.frame.height)
        }
        if let viewWidth = self.navigationController?.view.bounds.width,
            let viewCenter = self.navigationController?.view.center {
            loadingDataLable.frame.size = CGSize(width: viewWidth, height: 40)
            loadingDataLable.center = viewCenter
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    private func initalizeFetchedResultsController() {
        let favoriteStopRequest = NSFetchRequest(entityName: BusStop.entityName)
        favoriteStopRequest.predicate = NSPredicate(format: "favorited == %@", NSNumber(bool: true))
        favoriteStopRequest.sortDescriptors = [NSSortDescriptor(key: "actualName", ascending: true)]
        if let context = managedObjectContex {
            fetchedResultsController = NSFetchedResultsController(fetchRequest: favoriteStopRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            do {
                try fetchedResultsController?.performFetch()
            } catch {
                fatalError("Failed to initialize FetchedResultsController: \(error)")
            }
        } else {
            fatalError("FavoritesTableViewController does not have instance of managedObjectContext")
        }

    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.FavoriteStopCell, forIndexPath: indexPath)
        configureCell(cell, forIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: UITableViewCell, forIndexPath indexPath: NSIndexPath) {
        if let stop = fetchedResultsController?.objectAtIndexPath(indexPath) as? BusStop {
            if let cell = cell as? FavoriteStopTableViewCell {
                cell.stop = stop
            }
        }
    }

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */
    
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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.SelectRouteSegue {
            if let selectRouteTVC = segue.destinationViewController.contentViewController as? SelectRouteTableViewController {
                selectRouteTVC.managedObjectContex = managedObjectContex
                selectRouteTVC.title = "Select a Route"
            }
        }
    }
    
    @IBAction func cancelAddingFavoriteStop(segue:UIStoryboardSegue) {
    }
    
    @IBAction func addFavoriteStop(segue: UIStoryboardSegue) {
        _ = try? managedObjectContex?.save()

    }
}
