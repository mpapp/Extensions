//
//  Dictionary+Extensions.swift
//  Extensions
//
//  Created by Matias Piipari on 10/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

extension Dictionary {
    
    fileprivate static func JSONEncodableValue(_ value:Any) -> Any {
        if let v = value as? URL {
            return v.absoluteString as AnyObject
        }
        else if let v = value as? [Any] {
            return v.map { JSONEncodableValue($0) }
        }
        else if let v = value as? [Key:Any] {
            return v.JSONEncodable
        }
        
        return value
    }
    
    internal var JSONEncodable:[Key:Any] {
        var vs = [Key:Any]()
        for kp in self {
            let v = type(of: self).JSONEncodableValue(kp.1)
            vs[kp.0] = v
        }
        return vs
    }

}
