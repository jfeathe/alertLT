//
//  FavoriteStopTableViewCell.swift
//  alertLT
//
//  Created by Ryan Zegray on 2016-08-28.
//  Copyright © 2016 Ryan Zegray. All rights reserved.
//

import UIKit

class FavoriteStopTableViewCell: UITableViewCell {

    @IBOutlet weak var stopNameLabel: UILabel!
    @IBOutlet weak var routeNumbersLabel: UILabel!
    
    var stop: BusStop? {
        didSet {
            updateLabels()
        }
    }
    
    private func updateLabels() {
        if let customName = stop?.customName where customName != "" {
            stopNameLabel?.text = customName
           
        } else if let actualName = stop?.actualName {
            stopNameLabel?.text = actualName
            routeNumbersLabel.text = ""
        }
        
        guard let routes = stop?.routes?.allObjects as? [BusRoute] else {
            routeNumbersLabel.text = "No routes found that stop here"
            return
        }
        
        var listOfRoutesString = ""
        for (index, route) in routes.enumerate() {
            if index > 0 {
                listOfRoutesString += ","
            }
            if let direction = route.direction, let number = route.number  {
                listOfRoutesString += "\(number)\(direction.substringToIndex(direction.startIndex.successor())) "
            }
        }
        routeNumbersLabel.text = listOfRoutesString

    }

}
