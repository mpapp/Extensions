//
//  NSNumber+Extensions.swift
//  Extensions
//
//  Created by Matias Piipari on 11/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

extension NSNumber {
    var isBoolean:Bool {
        return CFNumberGetType(self as CFNumber) == CFNumberType.charType
    }
    
    var isFloatingPoint:Bool {
        return CFNumberIsFloatType(self as CFNumber)
    }
    
    var isIntegral:Bool {
        return CFNumberGetType(self as CFNumber).isIntegral
    }
}

extension CFNumberType {
    var isIntegral:Bool {
        let raw = self.rawValue
        return (raw >= CFNumberType.sInt8Type.rawValue && raw <= CFNumberType.sInt64Type.rawValue)
                || raw == CFNumberType.nsIntegerType.rawValue
                || raw == CFNumberType.longType.rawValue
                || raw == CFNumberType.longLongType.rawValue
    }
}
