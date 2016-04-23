//
//  String+Extensions.swift
//  Extensions
//
//  Created by Matias Piipari on 22/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation
import RegexKitLite

extension Character {
    public func isUpper() -> Bool {
        let characterString = String(self)
        return characterString == characterString.uppercaseString
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
    
    func componentsSeparated(tokenizingPatterns patterns:[String]) -> [String] {
        var tokenizedStrings = [self]
        for p in patterns {
            let cs = (self as NSString).componentsSeparatedByRegex(p) as! [String]
            if cs.count > 1 {
                tokenizedStrings = cs
                break
            }
        }
        
        return tokenizedStrings
    }
    
    func componentsCaptured(capturingPatterns patterns:[String]) -> [String] {
        var capturedStrings = [String]()
        for p in patterns {
            guard let cs = (self as NSString).captureComponentsMatchedByRegex(p) as? [String] where cs.count > 0 else {
                continue
            }
            
            // the first element needs excluding if matches were found (it represents the start of the match – the rest are capture groups)
            if cs.count > 1 {
                capturedStrings.appendContentsOf(cs[1..<cs.count])
            }
        }
        
        return capturedStrings
    }
}