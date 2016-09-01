//
//  FavoritesTableViewController.swift
//  alertLT
//
//  Created by Ryan Zegray on 2016-08-22.
//  Copyright © 2016 Ryan Zegray. All rights reserved.
//

import UIKit
import CoreData


class FavoritesTableViewController: FetchedResultsTableViewController {
    
    enum Constants {
        static let SelectRouteSegue = "SelectRouteSegue"
        static let ArrivalTimesSegue = "ArrivalTimesSegue"
        static let FavoriteStopCell = "FavoriteStopCell"
    }
    
    //UI Elements for the Loading Data Message
    
    let noFavoriteStopsLabel: UILabel = {
       let label =  UILabel()
        label.text = "You do not have any favorite stops  🙁"
        label.textColor = UIColor.grayColor()
        label.textAlignment = .Center
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        return label
    }()
    let noFavoriteStopsButton: UIButton = {
        let button = UIButton()
        button.setTitle("Find a stop!", forState: .Normal)
        button.setTitleColor(UIColor.lightBlueColor(), forState: .Normal)
        button.setTitleColor(UIColor.blueColor(), forState: .Highlighted)
        button.titleLabel?.textAlignment = .Center
        button.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        return button
    }()
    
    // MARK: Model
    
    static var managedObjectContex: NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    
    // MARK: Updating the background view UI for displaying messages to the user

    
    func showLoadingMessage() {
        
        if let navigationItems = navigationItem.rightBarButtonItems {
            for item in navigationItems {
                item.enabled = false
            }
        }
        if let tabBarItems = tabBarController?.tabBar.items {
            for item in tabBarItems {
                item.enabled = false
            }
        }
        noFavoriteStopsLabel.hidden = true
        noFavoriteStopsButton.hidden = true
        refreshControl?.attributedTitle = NSAttributedString(string: "Downloading the latest stop information 📡")
        self.refreshControl!.beginRefreshing()
        
    }
    
    private func hideLoadingMessage(dbUpdater: DatabaseUpdater) {
        
        if let items = navigationItem.rightBarButtonItems {
            for item in items {
                item.enabled = true
            }
        }
        if let tabBarItems = tabBarController?.tabBar.items {
            for item in tabBarItems {
                item.enabled = true
            }
        }
        noFavoriteStopsLabel.hidden = false
        noFavoriteStopsButton.hidden = false
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        if let lastUpdate = dbUpdater.lastUpdatedDate {
            refreshControl?.attributedTitle = NSAttributedString(string: "Last Updated on \(dateFormatter.stringFromDate(lastUpdate))")
        } else {
           refreshControl?.attributedTitle = NSAttributedString(string: "Pull to update" )
        }
        self.refreshControl?.endRefreshing()
    }
    
    private func showNoFavoritesMessage() {
        noFavoriteStopsButton.sizeToFit()
        noFavoriteStopsLabel.frame = CGRect(x: 0, y: self.view.bounds.midY, width: self.view.bounds.width, height: 35)
        noFavoriteStopsButton.frame.origin = CGPoint(
            x: noFavoriteStopsLabel.frame.midX - (noFavoriteStopsButton.bounds.width / 2),
            y: noFavoriteStopsLabel.frame.maxY
        )
        self.tableView.backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        
        self.tableView.backgroundView?.addSubview(noFavoriteStopsButton)
        self.tableView.backgroundView?.addSubview(noFavoriteStopsLabel)
        self.tableView.separatorStyle = .None
    }
    
    private func hideNoFavoritesMessage() {
        self.tableView.separatorStyle = .SingleLine
        noFavoriteStopsButton.removeFromSuperview()
        noFavoriteStopsLabel.removeFromSuperview()
    }
    
    ///Updates the database using a DatabaseUpdater instance. Pass in an array of stops if you want to limit which routes are updated
    
    @objc private func checkForUpdates() {
        let dbUpdater = DatabaseUpdater(context: FavoritesTableViewController.managedObjectContex)
        if dbUpdater.databaseShouldBeUpdated() {
            updateDatabaseUsing(dbUpdater)
        } else if let routesThatAreMissingInformation = dbUpdater.routesMissingInfo() where dbUpdater.missingRoutesShouldBeUpdated() {
            updateDatabaseUsing(dbUpdater, onlyUpdateRoutes: routesThatAreMissingInformation)
        }
    }
    
    @objc private func forceUpdate() {
        let dbUpdater = DatabaseUpdater(context: FavoritesTableViewController.managedObjectContex)
        updateDatabaseUsing(dbUpdater)
    }
    
    private func updateDatabaseUsing(dbUpdater: DatabaseUpdater) {
        updateDatabaseUsing(dbUpdater, onlyUpdateRoutes: nil)
    }
    
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
                dispatch_async(dispatch_get_main_queue()) {
                    let alert = UIAlertController(title: "No Internet Connection",message: "Please check your connection and try again later", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil ))
                    weakSelf?.presentViewController(alert, animated: true, completion: nil )
                }
            } catch {
                dispatch_async(dispatch_get_main_queue()) {
                    let alert = UIAlertController(title: "An Error has occured", message: "Unable to get LTC data please try again later", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Okay",style: .Default,handler: nil ))
                    weakSelf?.presentViewController(alert, animated: true, completion: nil )
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                weakSelf?.hideLoadingMessage(dbUpdater)
            }
        }
    }

    // MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        editButtonItem().tintColor = UIColor.whiteColor()
        noFavoriteStopsButton.addTarget(self, action: #selector(FavoritesTableViewController.noFavoriteStopsButtonPressed(_:)), forControlEvents: [.TouchUpInside])
        initalizeFetchedResultsController()
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(FavoritesTableViewController.forceUpdate), forControlEvents: .ValueChanged)
        self.refreshControl?.backgroundColor = UIColor.verylightGrayColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        checkForUpdates()
    }

    // MARK: - Table view data source
    
    private func initalizeFetchedResultsController() {
        let favoriteStopRequest = NSFetchRequest(entityName: BusStop.entityName)
        favoriteStopRequest.predicate = NSPredicate(format: "favorited == %@", NSNumber(bool: true))
        favoriteStopRequest.sortDescriptors = [NSSortDescriptor(key: "actualName", ascending: true)]
        if let context = FavoritesTableViewController.managedObjectContex {
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
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let numRows = fetchedResultsController?.sections?[section].numberOfObjects where numRows > 0 {
            hideNoFavoritesMessage()
            return numRows
        } else {
            showNoFavoritesMessage()
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.FavoriteStopCell, forIndexPath: indexPath)
        configureCell(cell, forIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: UITableViewCell, forIndexPath indexPath: NSIndexPath) {
        
        guard let favoriteStopCell = cell as? BusInfoTableViewCell,
            stop = fetchedResultsController?.objectAtIndexPath(indexPath) as? BusStop else {
                return
        }
        
        if let customName = stop.customName where customName != "" {
            favoriteStopCell.primaryTextLabel.text = customName
        } else if let actualName = stop.actualName {
            favoriteStopCell.primaryTextLabel.text = actualName
        }
        
        guard let unsortedRoutes = stop.routes?.allObjects as? [BusRoute] else {
            favoriteStopCell.secondaryTextLabel.text = "No routes found that stop at this stop"
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
        favoriteStopCell.secondaryTextLabel.text = listOfRoutesString
        
    }
    
    //Editing the tableview
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if let stop = fetchedResultsController?.objectAtIndexPath(indexPath) as? BusStop {
                stop.favorited = NSNumber(bool: false)
                stop.customName = nil
                _ = try? fetchedResultsController?.performFetch()
                _ = try? FavoritesTableViewController.managedObjectContex?.save()
            }
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
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
    
    @IBAction func addFavoriteStop(segue: UIStoryboardSegue) {
        _ = try? FavoritesTableViewController.managedObjectContex?.save()
    }
    
    @IBAction func cancelAddingFavoriteStop(segue:UIStoryboardSegue) {
        //If they chancel adding a favorite stop nothing needs to be done.
    }
    
    
    @objc private func noFavoriteStopsButtonPressed(sender: UIButton) {
        performSegueWithIdentifier(Constants.SelectRouteSegue, sender: sender)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.SelectRouteSegue {
            if let selectRouteTVC = segue.destinationViewController.contentViewController as? SelectRouteTableViewController {
                selectRouteTVC.managedObjectContex = FavoritesTableViewController.managedObjectContex
                selectRouteTVC.title = "Select a Route"
            }
        } else if segue.identifier == Constants.ArrivalTimesSegue {
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
