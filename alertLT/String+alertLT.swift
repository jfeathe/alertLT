//
//  String+alertLT.swift
//  alertLT
//
//  Created by Ryan Zegray on 2016-08-31.
//  Copyright © 2016 Ryan Zegray. All rights reserved.
//

import Foundation

extension String {
    
    /// Removes a given prefix if it exists
    mutating func removePrefix(string: String) {
        if self.hasPrefix(string) {
            self.removeRange(self.startIndex..<self.startIndex.advancedBy(string.characters.count))
        }
    }
    
    /// Removes a given suffix if it exists
    mutating func removeSuffix(string: String) {
        if self.hasSuffix(string) {
            self.removeRange(self.endIndex.advancedBy(-string.characters.count)..<self.endIndex)
        }
    }
    
    /// Removes any occurance of the given string
    mutating func removeString(string: String) {
        if self.containsString(string) {
            let components = self.componentsSeparatedByString(string)
            self =  components.joinWithSeparator("")
        }
    }
    
    /// Removes that removes excess spaces in a sentence Ex. "The    Dog   Is    Blue" becomes "The Dog Is Blue"
    mutating func removeExcessSpaces() {
        let characters = self.characters
        
        //Start with empty string. If the suffix of the new string is a space
        //and the next character to add is a space then dont do anything
        //otherwise it is safe to append the next character to the new string
        let result: String = characters.reduce("")  {
            ($0.hasSuffix(" ") && String($1) == " ") ? $0 : $0.stringByAppendingString(String($1))
        }
        self = result
    }
}