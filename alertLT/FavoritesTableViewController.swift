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
    
    // MARK: Model
    
    var managedObjectContex: NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    
    // MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addFavoriteButtonItem = UIBarButtonItem(title: "＋", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(addFavoritesButtonPressed))
        addFavoriteButtonItem.setTitleTextAttributes([ NSFontAttributeName: UIFont.systemFontOfSize(23)], forState: .Normal)
        self.navigationItem.rightBarButtonItems = [self.editButtonItem(), addFavoriteButtonItem]
        
        
    }
    
    func addFavoritesButtonPressed() {
        performSegueWithIdentifier("SelectRouteSegue", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "SelectRouteSegue" {
            if let selectRouteTVC = segue.destinationViewController.contentViewController as? SelectRouteTableViewController {
                selectRouteTVC.managedObjectContex = managedObjectContex
                selectRouteTVC.title = "Select a Route"
            }
        }
    }
}

extension UIViewController {
    var contentViewController: UIViewController {
        //if what we are seguing to is actually a navigation controller get the "content" / visable view controller
        if let navCon = self as? UINavigationController {
            return navCon.visibleViewController ?? self
            //otherwise just return self since we are the contnet
        } else {
            return self
        }
    }
}
