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
        return characterString == characterString.uppercased()
    }
}

extension String {
    public func isUpper() -> Bool {
        for chr in self {
            if !chr.isUpper() {
                return false
            }
        }
        
        return true
    }
    
    public func capturedCharacterIndexRanges(capturingPatterns patterns:[String]) -> [CountableClosedRange<UInt>] {
        let capturedRanges = patterns.flatMap { pattern -> [CountableClosedRange<UInt>] in
            var ranges = [CountableClosedRange<UInt>]()
            
            (self as NSString).enumerateStrings(matchingRegex: pattern, with: { (captureCount, _, capturedRanges:UnsafePointer<NSRange>?, _) in
                guard let captRanges = capturedRanges else {
                    return
                }
                
                for c in 1 ..< captureCount {
                    let r = captRanges.advanced(by: c).pointee
                    let range = UInt(r.location) ... UInt(r.location + r.length)
                    ranges.append(range)
                }
            })
            
            return ranges
        }
        
        return capturedRanges
    }
    
    public func capturedRanges(capturingPatterns patterns:[String]) -> [Range<String.Index>] {
        return self.capturedCharacterIndexRanges(capturingPatterns: patterns).map { range -> Range<String.Index> in
            return self.index(self.startIndex, offsetBy: Int(range.lowerBound)) ..< self.index(self.startIndex, offsetBy: Int(range.lowerBound + range.upperBound))
        }
    }
    
    public func componentsSeparated(tokenizingPatterns patterns:[String]) -> [String] {
        var tokenizedStrings = [self]
        for p in patterns {
            let cs = (self as NSString).componentsSeparated(byRegex: p) as! [String]
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
            guard let cs = (self as NSString).captureComponents(matchedByRegex: p) as? [String], cs.count > 0 else {
                continue
            }
            
            // the first element needs excluding if matches were found (it represents the start of the match – the rest are capture groups)
            if cs.count > 1 {
                capturedStrings.append(contentsOf: cs[1..<cs.count])
            }
        }
        
        return capturedStrings
    }
    
    public func ranges(_ string:String, options:NSString.CompareOptions = [], locale:Locale? = nil) -> [(Range<String.Index>)] {
        var ranges = [Range<String.Index>]()
        var range:Range<String.Index>? = nil
        
        repeat {
            range = self.range(of: string, options: options, range: range, locale: locale)
            if let r = range {
                ranges.append(r)
                range = r.upperBound ..< self.endIndex
            }
        }
        while (range != nil)
        
        return ranges
    }
}
