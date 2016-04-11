//
//  Dictionary+Extensions.swift
//  Extensions
//
//  Created by Matias Piipari on 10/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

extension Dictionary where Key:Hashable, Value:AnyObject {
    
    private static func JSONEncodableValue(value:AnyObject) -> AnyObject {
        if let v = value as? NSURL {
            return v.absoluteString
        }
        else if let v = value as? [AnyObject] {
            return v.map { JSONEncodableValue($0) }
        }
        else if let v = value as? [Key:AnyObject] {
            return v.JSONEncodable as! AnyObject
        }
        
        return value
    }
    
    internal var JSONEncodable:[Key:AnyObject] {
        var vs = [Key:AnyObject]()
        for kp in self {
            let v = self.dynamicType.JSONEncodableValue(kp.1)
            vs[kp.0] = v
        }
        return vs
    }

}