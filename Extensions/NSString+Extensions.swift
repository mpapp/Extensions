//
//  NSString+Extensions.swift
//  Extensions
//
//  Created by Matias Piipari on 02/06/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

public extension NSString {
    func mp_capturedRanges(capturingPatterns patterns: [String]) -> NSArray {
        let items = (self as String).capturedRanges(capturingPatterns: patterns).map { range -> NSRange in
            let string = (self as String)
            
            return NSRange(location: string.distance(from: string.startIndex, to: range.lowerBound),
                           length: string.distance(from: range.lowerBound, to: range.upperBound))
        }

        return items as NSArray
    }
}
