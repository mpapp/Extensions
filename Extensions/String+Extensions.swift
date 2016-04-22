//
//  String+Extensions.swift
//  Extensions
//
//  Created by Matias Piipari on 22/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

extension Character {
    public func isUpper() -> Bool {
        let characterString = String(self)
        return (characterString == characterString.uppercaseString) && (characterString != characterString.lowercaseString)
    }
}

extension String {
    func isUpper() -> Bool {
        for chr in self.characters {
            if !chr.isUpper() {
                return false
            }
        }
        
        return true
    }
}