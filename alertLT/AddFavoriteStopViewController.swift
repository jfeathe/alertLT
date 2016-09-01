//
//  AddFavoriteStopViewController.swift
//  alertLT
//
//  Created by Ryan Zegray on 2016-08-27.
//  Copyright © 2016 Ryan Zegray. All rights reserved.
//

import UIKit

class AddFavoriteStopViewController: UIViewController {

    private enum Constants {
        static let AddFavoriteStopSegue = "AddFavoriteStopSegue"
    }
    
    // MARK: Model
    var route: BusRoute?
    var stop: BusStop?
    
    // MARK: UI Elements
    
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var routeLabel: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var stopLabel: UILabel!
    
    private func updateLabels() {
        if let routeNumber = route?.number, routeName = route?.name, routeDirection = route?.direction {
            routeLabel?.text = "\(routeNumber) - \(routeName)"
            directionLabel?.text = routeDirection
        }
        
        if let stopNumber = stop?.number, stopName = stop?.actualName {
            stopLabel?.text = "\(stopNumber) - \(stopName)"
            
            if let customStopName = stop?.customName {
                nicknameTextField?.text = customStopName
            }
        }
    }
    // MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLabels()
        let doneButton = UIBarButtonItem(title: "Done", style: .Done, target: self, action: #selector(AddFavoriteStopViewController.doneButtonPressed))
        self.navigationItem.rightBarButtonItem = doneButton
    }
    
    // MARK: - Navigation

    @objc private func doneButtonPressed() {
        performSegueWithIdentifier(Constants.AddFavoriteStopSegue, sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.AddFavoriteStopSegue {
            stop?.favorited = NSNumber(bool: true)
            stop?.customName = nicknameTextField?.text
        }
    }
    

}
