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
    
    enum Constants {
        static let SelectRouteSegue = "SelectRouteSegue"
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

    }

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
}
