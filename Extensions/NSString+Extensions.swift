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
            return NSMakeRange((self as String).startIndex.distanceTo(range.startIndex), range.startIndex.distanceTo(range.endIndex))
        }
        
        return items as NSArray
    }
}