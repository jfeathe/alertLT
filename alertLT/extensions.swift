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
        if self.hasPrefix(string) {
            self.removeRange(self.startIndex..<self.startIndex.advancedBy(string.characters.count))
        }
    }
    
    mutating func removeSuffix(string: String) {
        if self.hasSuffix(string) {
            self.removeRange(self.endIndex.advancedBy(-string.characters.count)..<self.endIndex)
        }
    }
    
    mutating func removeString(string: String) {
        if self.containsString(string) {
            let components = self.componentsSeparatedByString(string)
            self =  components.joinWithSeparator("")
        }
    }
    
    mutating func removeExcessSpaces() {
        let characters = self.characters
        //Start with empty string. If the previous character was a space and the next character to add is a space
        //Dont do anything. Otherwise it is safe to append the next character }
        let result: String = characters.reduce("")  { ($0.hasSuffix(" ") && String($1) == " ") ? $0 : $0.stringByAppendingString(String($1)) }
        self = result
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