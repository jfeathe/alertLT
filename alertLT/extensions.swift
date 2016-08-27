//
//  extensions.swift
//  alertLT
//
//  Created by Ryan Zegray on 2016-08-27.
//  Copyright © 2016 Ryan Zegray. All rights reserved.
//

import Foundation
import UIKit

extension String {

    mutating func removePrefix(string: String) {
        self.removeRange(self.startIndex...self.startIndex.advancedBy(string.characters.count))
    }
    
    mutating func removeSuffix(string: String) {
        self.removeRange(self.endIndex.advancedBy(-string.characters.count)..<self.endIndex)
    }
    
    mutating func removeString(string: String) {
        let components = self.componentsSeparatedByString(string)
        self =  components.joinWithSeparator("")
    }
}

extension UIViewController {
    var contentViewController: UIViewController {
        if let navCon = self as? UINavigationController {
            return navCon.visibleViewController ?? self
        } else {
            return self
        }
    }
}