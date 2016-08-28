//
//  AddFavoriteStopViewController.swift
//  alertLT
//
//  Created by Ryan Zegray on 2016-08-27.
//  Copyright © 2016 Ryan Zegray. All rights reserved.
//

import UIKit

class AddFavoriteStopViewController: UIViewController {

    
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var routeLabel: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var stopLabel: UILabel!
    
    private enum Constants {
        static let AddFavoriteStopSegue = "AddFavoriteStopSegue"
    }
    
    // MARK: Model
    var route: BusRoute?
    var stop: BusStop?
    
    private func updateLabelsUsingRouteInformation() {
        if let routeNumber = route?.number, routeName = route?.name, routeDirection = route?.direction {
            routeLabel?.text = "\(routeNumber) - \(routeName)"
            directionLabel?.text = routeDirection
        }
    }
    
    private func updateLabelsUsingStopInformation() {
        if let stopNumber = stop?.number, stopName = stop?.actualName {
            stopLabel?.text = "\(stopNumber) - \(stopName)"
        }
    }
    
    // MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLabelsUsingStopInformation()
        updateLabelsUsingRouteInformation()
        let doneButton = UIBarButtonItem(title: "Done", style: .Done, target: self, action: #selector(AddFavoriteStopViewController.doneButtonPressed))
        self.navigationItem.rightBarButtonItem = doneButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func doneButtonPressed() {
        performSegueWithIdentifier(Constants.AddFavoriteStopSegue, sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.AddFavoriteStopSegue {
            stop?.favorited = NSNumber(bool: true)
            stop?.customName = nicknameTextField?.text
        }
    }
    

}
