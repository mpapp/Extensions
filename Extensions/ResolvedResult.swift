//
//  ResolvedResult.swift
//  Extensions
//
//  Created by Matias Piipari on 25/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

public enum ResolvedResult {
    case None(Resolvable)
    case BibliographyItems(Resolvable, [BibliographyItem])
    case InlineMathFragments(Resolvable, [InlineMathFragment])
    case Equations(Resolvable, [Equation])
    case BlockElements(Resolvable, [BlockElement])
    case InlineElements(Resolvable, [InlineElement])
    
    public var dictionaryRepresentation:[String:AnyObject] {
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
            
            guard let dictRep = dictAssoc?.value as? DictionaryRepresentable else {
                preconditionFailure("Enum option \(self) does not have a dictionary representable second value: \(mirror.children)")
            }
            
            guard let label = dictAssoc?.label else {
                preconditionFailure("Enum option \(self) does not have a label.")
            }
            
            return ["type":label,
                    "resolvable":resolvable.identifier,
                    "value":dictRep.dictionaryRepresentation]
        }
    }
    
    public var HTMLSnippetRepresentables:[HTMLSnippetRepresentable] {
        switch self {
        case None(_):
            return []
            
        default:
            let mirror = Mirror(reflecting: self)
            let associatedCount = mirror.children.count
            
            guard associatedCount == 2 else {
                preconditionFailure("Enum option \(self) has unexpected numbers of value.")
            }
            
            guard let _ = mirror.children.dropFirst().first?.value as? Resolvable else {
                preconditionFailure("Enum option \(self) does not have an associated value.")
            }
            
            let htmlRepsAssoc = mirror.children.dropFirst().first
            
            guard let htmlReps = htmlRepsAssoc?.value as? [HTMLSnippetRepresentable] else {
                print("Enum option \(self) does not have a HTML snippet representable second value: \(mirror.children)")
                return []
            }
            
            return htmlReps
        }
    }
}
