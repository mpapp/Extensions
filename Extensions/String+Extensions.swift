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

            guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
                return []
            }
            regex.enumerateMatches(in: self,
                                   options: [],
                                   range: NSRange(self.startIndex..<self.endIndex, in: self)) { (checkingResult, _, stop) in
                                    if let checkingResult = checkingResult {
                                        for capturedRangeIndex in 0..<(checkingResult.numberOfRanges - 1) {
                                            let nsRange = checkingResult.range(at: capturedRangeIndex)
                                            let capturedRange = UInt(nsRange.lowerBound)...UInt(nsRange.upperBound)
                                            ranges.append(capturedRange)
                                        }
                                    }
                                    stop.pointee = true
            }
            
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

            let components = self.componentsSeparated(byRegex: p)
            if components.count > 1 {
                tokenizedStrings = components
                break
            }
        }
        
        return tokenizedStrings
    }

    public func componentsSeparated(byRegex regex: String) -> [String] {
        var ranges: [Range<String.Index>] = []
        var startIndex = self.startIndex

        while startIndex < self.endIndex,
            let range = self[startIndex...].range(of: regex, options: .regularExpression) {
                ranges.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }

        return ranges.map { String(self[$0]) }
    }
    
    public func componentsCaptured(capturingPatterns patterns:[String]) -> [String] {
        var capturedStrings = [String]()
        for p in patterns {
            var stringsForPattern = [String]()
            guard let regex = try? NSRegularExpression(pattern: p, options: []) else {
                return []
            }
            regex.enumerateMatches(in: self,
                                   options: [],
                                   range: NSRange(self.startIndex..<self.endIndex, in: self)) { (checkingResult, _, stop) in
                                    if let checkingResult = checkingResult {
                                        for capturedRangeIndex in 0..<(checkingResult.numberOfRanges - 1) {
                                            if let capturedRange = Range(checkingResult.range(at: capturedRangeIndex), in: self) {
                                                stringsForPattern.append(String(self[capturedRange]))
                                            }
                                        }
                                    }
                                    stop.pointee = true
            }

            guard stringsForPattern.count > 0 else {
                continue
            }

            // the first element needs excluding if matches were found (it represents the start of the match – the rest are capture groups)
            if stringsForPattern.count > 1 {
                capturedStrings.append(contentsOf: stringsForPattern[1..<stringsForPattern.count])
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
