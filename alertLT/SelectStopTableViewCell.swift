//
//  SelectStopTableViewCell.swift
//  alertLT
//
//  Created by Ryan Zegray on 2016-08-26.
//  Copyright © 2016 Ryan Zegray. All rights reserved.
//

import UIKit

class SelectStopTableViewCell: UITableViewCell {

    @IBOutlet weak var stopNumberLabel: UILabel!
    @IBOutlet weak var stopDescriptionLabel: UILabel!
    
    var busStop: BusStop? {
        didSet {
            updateLabels()
        }
    }
    
    private func updateLabels() {
        if let name = busStop?.actualName, number = busStop?.number {
            stopNumberLabel?.text = String(number)
            stopDescriptionLabel?.text = name
        }
    }
    
}

