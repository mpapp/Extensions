//
//  Dictionary+Extensions.swift
//  Extensions
//
//  Created by Matias Piipari on 10/04/2016.
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
