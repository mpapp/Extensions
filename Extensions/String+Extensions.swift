//
//  String+Extensions.swift
//  Extensions
//
//  Created by Matias Piipari on 22/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//
//  ---------------------------------------------------------------------------
//
//  © 2019 Atypon Systems LLC
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

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
    
    public func capturedRanges(capturingPatterns patterns:[String]) -> [Range<String.Index>] {
        var capturedRanges = [Range<String.Index>]()
        for p in patterns {
            guard let regex = try? NSRegularExpression(pattern: p, options: []) else {
                return []
            }

            let results = regex.matches(in: self,
                                        options: [],
                                        range: NSRange(self.startIndex..., in: self))
            for checkingResult in results {
                for capturedRangeIndex in 0..<checkingResult.numberOfRanges {
                    if let capturedRange = Range(checkingResult.range(at: capturedRangeIndex), in: self) {
                        capturedRanges.append(capturedRange)
                    }
                }
            }
        }

        return capturedRanges
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
            let regexRange = self[startIndex...].range(of: regex, options: .regularExpression) {
                ranges.append(startIndex..<regexRange.lowerBound)
                startIndex = regexRange.lowerBound < regexRange.upperBound ? regexRange.upperBound :
                    index(regexRange.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }

        // Last component range
        ranges.append(startIndex..<endIndex)

        return ranges.map { String(self[$0]) }
    }
    
    public func componentsCaptured(capturingPatterns patterns:[String]) -> [String] {
        return capturedRanges(capturingPatterns: patterns).map { range -> String in
            return String(self[range])
        }
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
