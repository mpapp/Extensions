//
//  SequenceType+Extensions.swift
//  Extensions
//
//  Created by Matias Piipari on 13/05/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

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
