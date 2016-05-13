//
//  SequenceType+Extensions.swift
//  Extensions
//
//  Created by Matias Piipari on 13/05/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

extension CollectionType {
    
    public typealias ElementPair = (Generator.Element, Generator.Element)
    
    public func forEachPair(@noescape body: (ElementPair) throws -> Void) rethrows -> Void {
        for i in self.indices {
            for j in i.successor() ..< self.endIndex {
                try body((self[i], b: self[j]))
            }
        }
    }
    
}