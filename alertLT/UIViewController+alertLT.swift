//
//  extensions.swift
//  alertLT
//
//  Created by Ryan Zegray on 2016-08-27.
//  Copyright © 2016 Ryan Zegray. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    /// Returns the Visable View Controller if a View Controller has one
    var contentViewController: UIViewController {
        if let navCon = self as? UINavigationController {
            return navCon.visibleViewController ?? self
        } else {
            return self
        }
    }
}
