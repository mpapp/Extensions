//
//  NSString+Extensions.swift
//  Extensions
//
//  Created by Matias Piipari on 02/06/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

public extension NSString {
    public func mp_capturedRanges(capturingPatterns patterns:[String]) -> NSArray {
        let items = (self as String).capturedRanges(capturingPatterns: patterns).map { range -> NSRange in
            let characterView = (self as String).characters
            
            return NSRange(location: characterView.distance(from: characterView.startIndex, to: range.lowerBound),
                           length: characterView.distance(from: range.lowerBound, to: range.upperBound))
        }

        return items as NSArray
    }
}
