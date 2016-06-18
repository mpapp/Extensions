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
    public func isUpper() -> Bool {
        for chr in self.characters {
            if !chr.isUpper() {
                return false
            }
        }
        
        return true
    }
    
    public func capturedCharacterIndexRanges(capturingPatterns patterns:[String]) -> [Range<UInt>] {
        let capturedRanges = patterns.flatMap { pattern -> [Range<UInt>] in
            var ranges = [Range<UInt>]()
            (self as NSString).enumerateStringsMatchedByRegex(pattern, usingBlock: { (captureCount, _, capturedRanges:UnsafePointer<NSRange>, _) in
                
                for c in (1 ..< captureCount) {
                    let r = capturedRanges.advancedBy(c).memory
                    let range = UInt(r.location) ..< UInt(r.location + r.length)
                    ranges.append(range)
                }
            })
            
            return ranges
        }
        
        return capturedRanges
    }
    
    public func capturedRanges(capturingPatterns patterns:[String]) -> [Range<String.CharacterView.Index>] {
        return self.capturedCharacterIndexRanges(capturingPatterns: patterns).map { range -> Range<String.CharacterView.Index> in
            return self.characters.startIndex.advancedBy(Int(range.startIndex)) ..< self.characters.startIndex.advancedBy(Int(range.startIndex + range.endIndex))
        }
    }
    
    public func componentsSeparated(tokenizingPatterns patterns:[String]) -> [String] {
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
    
    public func componentsCaptured(capturingPatterns patterns:[String]) -> [String] {
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
    
    public func ranges(string:String, options:NSStringCompareOptions = [], locale:NSLocale? = nil) -> [(Range<String.CharacterView.Index>)] {
        var ranges = [Range<String.Index>]()
        var range:Range<String.Index>? = nil
        
        repeat {
            range = self.rangeOfString(string, options: options, range: range, locale: locale)
            if let r = range {
                ranges.append(r)
                range = r.endIndex ..< self.endIndex
            }
        }
        while (range != nil)
        
        return ranges
    }
}
