//
//  ResolverService.swift
//  Extensions
//
//  Created by Matias Piipari on 20/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

public enum ResolvedResult {
    case None
    case BibliographyItems([BibliographyItem])
    case InlineMathFragments([InlineMathFragment])
    case Equations([Equation])
    case BlockElements([BlockElement])
    
    func dictionaryRepresentation() -> [String:AnyObject] {
        switch self {
        case None:
            return [:]
            
        default:
            let mirror = Mirror(reflecting: self)
            
            guard let associated = mirror.children.first else {
                preconditionFailure("Enum option \(self) does not have an associated value")
            }
            
            guard let label = associated.label else {
                preconditionFailure("Enum option \(self) does not have a label.")
            }
            
            guard let dict = associated.value as? DictionaryRepresentable else {
                preconditionFailure("Associated value of \(self) is not dictionary representable.")
            }
            
            return ["type":label,"value":dict]
        }
    }
}

public protocol Resolver {
    var resolvableType:Resolvable.Type { get }
    
    func baseURL() -> NSURL
    func resolve(identifier:String) throws -> ResolvedResult
}