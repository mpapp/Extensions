//
//  ResolvedResult.swift
//  Extensions
//
//  Created by Matias Piipari on 25/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

public typealias ResolvableTuple = (Resolvable)
public typealias ResolvableBibliographyItemsTuple = (resolvable:Resolvable, items:[BibliographyItem])
public typealias ResolvableInlineMathFragmentsTuple = (resolvable:Resolvable, items:[InlineMathFragment])
public typealias ResolvableEquationsTuple = (resolvable:Resolvable, items:[Equation])
public typealias ResolvableBlockElementsTuple = (resolvable:Resolvable, items:[BlockElement])
public typealias ResolvableInlineElementsTuple = (resolvable:Resolvable, items:[InlineElement])

internal typealias LabelItemsTuple = (String?, (Resolvable, HTMLSnippetRepresentable))

public enum Result {
    case None
    case BibliographyItems(items:[BibliographyItem])
    case InlineMathFragments(items:[InlineMathFragment])
    case Equations(items:[Equation])
    case BlockElements(items:[BlockElement])
    case InlineElements(items:[InlineElement])
}

public struct ResolvedResult {
    
    public let resolvable:Resolvable
    public let result:Result
    
    public var dictionaryRepresentation:[String:AnyObject] {
        switch self.result {
        case .None:
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
        switch self.result {
        case .None:
            return []
            
        default:
            let mirror = Mirror(reflecting: self)
            
            guard let htmlReps = mirror.children.first?.value as? [HTMLSnippetRepresentable] else {
                return []
            }
            
            return htmlReps
        }
    }
}
