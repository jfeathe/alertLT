//
//  SelectRouteTableViewController.swift
//  alertLT
//
//  Created by Ryan Zegray on 2016-08-24.
//  Copyright © 2016 Ryan Zegray. All rights reserved.
//

import UIKit
import CoreData

class SelectRouteTableViewController: UITableViewController {
    
    private enum Constants {
        static let dateLastUpdatedKey = "DateLastUpdated"
    }
    
    //Outlets and UIElements
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
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
    var managedObjectContex: NSManagedObjectContext?
    
    
    // MARK: Methods for checking / updating database
    
    func updateDatabase(dbUpdater: DatabaseUpdater) {
        
        showLoadingMessage()
        //Go to a different queue to load data from the webwatch website
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak weakSelf = self] in
            do {
                try dbUpdater.updateDatabase()
            // TODO: Handel Errors
            } catch WebWatchError.CannotGetContentsOfURL {
                print(1)
            } catch WebWatchError.InvalidURL {
                print(2)
            } catch {
                print(3)
            }
            //Go back to main queue and update UI
            dispatch_async(dispatch_get_main_queue()) {
                weakSelf?.hideLoadingMessage()
                dbUpdater.printDatabaseContents()
            }
        }
    }
    
    private func updateRoutes(routes: [BusRoute], withUpdater dbUpdater: DatabaseUpdater) {
        
        showLoadingMessage()
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak weakSelf = self] in
            do {
                try dbUpdater.updateRoutes(routes)
                // TODO: Handel Errors
            } catch WebWatchError.CannotGetContentsOfURL {
                print(1)
            } catch WebWatchError.InvalidURL {
                print(2)
            } catch {
                print(3)
            }
            //Go back to main queue and update UI
            dispatch_async(dispatch_get_main_queue()) {
                weakSelf?.hideLoadingMessage()
            }
        }
    }
    
    func showLoadingMessage() {
        self.navigationController?.view.addSubview(loadingDataLable)
        self.navigationController?.view.addSubview(loadingDataSpinner)
        loadingDataLable.hidden = false
        loadingDataSpinner.hidden = false
        loadingDataSpinner.startAnimating()
        cancelBarButton.enabled = false
        tableView?.scrollEnabled = false
    }
    
    private func hideLoadingMessage() {
        loadingDataLable.hidden = true
        loadingDataSpinner.hidden = true
        cancelBarButton.enabled = true
        tableView?.scrollEnabled = true
    }
    
    // MARK View Controller Lifecycle

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        if let viewCenter = self.navigationController?.view.center {
            loadingDataSpinner.center = CGPoint(x: viewCenter.x, y: viewCenter.y - loadingDataLable.frame.height)
        }
        if let viewWidth = self.navigationController?.view.bounds.width,
            let viewCenter = self.navigationController?.view.center {
            loadingDataLable.frame.size = CGSize(width: viewWidth, height: 40)
            loadingDataLable.center = viewCenter
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        let dbUpdater = DatabaseUpdater(context: managedObjectContex)
        if dbUpdater.databaseShouldBeUpdated() {
            updateDatabase(dbUpdater)
        } else if let routesWithMissingInfo = dbUpdater.routesMissingInfo() where dbUpdater.missingRoutesShouldBeUpdated() {
            updateRoutes(routesWithMissingInfo, withUpdater: dbUpdater)
        }
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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
