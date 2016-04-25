//
//  ResolverService.swift
//  Extensions
//
//  Created by Matias Piipari on 20/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

public enum ResolvedResult {
    case None(Resolvable)
    case BibliographyItems(Resolvable, [BibliographyItem])
    case InlineMathFragments(Resolvable, [InlineMathFragment])
    case Equations(Resolvable, [Equation])
    case BlockElements(Resolvable, [BlockElement])
    case InlineElements(Resolvable, [InlineElement])
    
    func dictionaryRepresentation() -> [String:AnyObject] {
        switch self {
        case None(let resolvable):
            return ["type":"None", "resolvable":resolvable.identifier, "value":[:]]
            
        default:
            let mirror = Mirror(reflecting: self)
            let associatedCount = mirror.children.count
            
            guard associatedCount == 2 else {
                preconditionFailure("Enum option \(self) has unexpected numbers of value.")
            }
            
            guard let resolvable = mirror.children.dropFirst().first?.value as? Resolvable else {
                preconditionFailure("Enum option \(self) does not have an associated value.")
            }
            
            let dictAssoc = mirror.children.dropFirst().first
            
            guard let dict = dictAssoc?.value as? DictionaryRepresentable else {
                preconditionFailure("Enum option \(self) does not have a dictionary representable second value: \(mirror.children)")
            }
            
            guard let label = dictAssoc?.label else {
                preconditionFailure("Enum option \(self) does not have a label.")
            }
            
            return ["type":label,
                    "resolvable":resolvable.identifier,
                    "value":dict.dictionaryRepresentation()]
        }
    }
    
}

public let ResolverRateLimitMilliseconds = 100

public protocol Resolver {
    var resolvableType:Resolvable.Type { get }
    
    func resolve(identifier:String) throws -> ResolvedResult
    
    var rateLimitLabel:String { get }
    var rateLimit:NSTimeInterval { get }
}

public protocol URLBasedResolver:Resolver {
    func baseURL() -> NSURL
}

public extension Resolver {
    
    public var rateLimitLabel:String {
        return String(self.dynamicType)
    }
    
    public var rateLimit:NSTimeInterval {
        return 1.0
    }
    
}