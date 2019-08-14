//
//  NSString+Extensions.swift
//  Extensions
//
//  Created by Matias Piipari on 02/06/2016.
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
