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
    case BibliographyItems([BibliographyItem])
    case InlineMathFragments([InlineMathFragment])
    case Equations([Equation])
    case BlockElements([BlockElement])
    case InlineElements([InlineElement])
    
    public var HTMLSnippetRepresentables:[HTMLSnippetRepresentable] {
        switch self {
        case .None:
            return []

        case .BibliographyItems(let items):
            return items.map { $0 }
        
        case .BlockElements(let items):
            return items.map { $0 }
        
        case .Equations(let items):
            return items.map { $0 }
        
        case .InlineElements(let items):
            return items.map { $0 }
        
        case .InlineMathFragments(let items):
            return items.map { $0 }
        }
    }
}

extension Result: CustomStringConvertible {
    public var description: String {
        switch self {
        case .None:
            return "<Empty Result>"
            
        case .BibliographyItems(let items):
            return items.map({$0.description }).joinWithSeparator(",")
        
        case .BlockElements(let items):
            return items.map({$0.description }).joinWithSeparator(",")
            
        case .Equations(let items):
            return items.map({$0.description}).joinWithSeparator(",")
            
        case .InlineElements(let items):
            return items.map({$0.description}).joinWithSeparator(",")
            
        case .InlineMathFragments(let fragments):
            return fragments.map({$0.description}).joinWithSeparator(",")
        }
    }
}

@objc public class ResolvedResult: NSObject, DictionaryRepresentable, ElementRepresentable {
    public let resolvable:Resolvable
    public let result:Result
    
    public init(resolvable:Resolvable, result:Result) {
        self.resolvable = resolvable
        self.result = result
    }
    
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
    
    public func elementRepresentation() throws -> Element {
        let htmlReps = self.result.HTMLSnippetRepresentables
        
        if let firstRep = htmlReps.first where htmlReps.count == 1 {
            return try element(HTMLSnippet: firstRep.HTMLSnippetRepresentation)
        }
        
        let contents = htmlReps.map { $0.HTMLSnippetRepresentation }
        return try element(tagName: "div", contents: contents.joinWithSeparator(""))
    }
}
