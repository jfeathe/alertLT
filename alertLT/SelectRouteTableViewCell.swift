//
//  SelectRouteTableViewCell.swift
//  alertLT
//
//  Created by Ryan Zegray on 2016-08-26.
//  Copyright © 2016 Ryan Zegray. All rights reserved.
//

import UIKit

class SelectRouteTableViewCell: UITableViewCell {
    @IBOutlet weak var routeNumberLable: UILabel!
    @IBOutlet weak var routeDescriptionLabel: UILabel!
    
    var busRoute: BusRoute? {
        didSet {
            updateLabels()
        }
    }
    
    private func updateLabels() {
        if let name = busRoute?.name, number = busRoute?.number, direction = busRoute?.direction {
            if String(number).characters.count < 2 {
                routeNumberLable?.text = "0" + String(number)
            } else {
                routeNumberLable?.text = String(number)
            }
            routeDescriptionLabel.text = name + " - " + direction.substringToIndex(direction.startIndex.successor())
        }
    }
}
