//
//  PDBIDProcessor.swift
//  Extensions
//
//  Created by Matias Piipari on 20/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

public class ResolvableProcessor: FragmentProcessor {
    
    private let resolver:Resolver
    
    public var tokenizingPatterns: [String] {
        return ["\\s+"]
    }
    
    init(resolver:Resolver) {
        self.resolver = resolver
    }
    
    public func process(textFragment fragment: String) throws -> String {
        
        let dicts = ProteinDataBankResolver().resolve(Resolvable(fragment).map {
            return $0.dictionaryRepresentation
        }
        
        return String(data: (try NSJSONSerialization.dataWithJSONObject(dicts, options: [])), encoding: NSUTF8StringEncoding) ?? fragment
    }
}

