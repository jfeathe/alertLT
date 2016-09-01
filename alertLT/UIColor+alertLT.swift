//
//  UIColor+alertLT.swift
//  alertLT
//
//  Created by Ryan Zegray on 2016-08-31.
//  Copyright © 2016 Ryan Zegray. All rights reserved.
//

import Foundation
import UIKit

/// Added extra colors to UIColor to use throughout the app
extension UIColor {
    static func verylightGrayColor() -> UIColor {
        return UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
    }
    
    static func darkGreenColor() -> UIColor {
        return UIColor(red:0.00, green:0.60, blue:0.20, alpha:1.0)
    }
    
    static func lightBlueColor() -> UIColor {
        return UIColor(red:0.00, green:0.40, blue:1.00, alpha:1.0)
    }
}