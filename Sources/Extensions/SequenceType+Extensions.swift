//
//  SequenceType+Extensions.swift
//  Extensions
//
//  Created by Matias Piipari on 13/05/2016.
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

extension Collection {
    
    public typealias ElementPair = (Iterator.Element, Iterator.Element)
    
    public func forEachPair( body: (ElementPair) throws -> Void) rethrows -> Void {
        for i in self.indices {
            for j in self.suffix(from: self.index(after: i)) {
                let a = self[i]
                try body((a, b: j))
            }
        }
    }
    
}
