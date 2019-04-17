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
    case none
    case bibliographyItems([BibliographyItem])
    case inlineMathFragments([InlineMathFragment])
    case equations([Equation])
    case blockElements([BlockElement])
    case inlineElements([InlineElement])
    
    public var HTMLSnippetRepresentables:[HTMLSnippetRepresentable] {
        switch self {
        case .none:
            return []

        case .bibliographyItems(let items):
            return items.map { $0 }
        
        case .blockElements(let items):
            return items.map { $0 }
        
        case .equations(let items):
            return items.map { $0 }
        
        case .inlineElements(let items):
            return items.map { $0 }
        
        case .inlineMathFragments(let items):
            return items.map { $0 }
        }
    }
}

extension Result: CustomStringConvertible {
    public var description: String {
        switch self {
        case .none:
            return "<Empty Result>"
            
        case .bibliographyItems(let items):
            return items.map({$0.description }).joined(separator: ",")
        
        case .blockElements(let items):
            return items.map({$0.description }).joined(separator: ",")
            
        case .equations(let items):
            return items.map({$0.description}).joined(separator: ",")
            
        case .inlineElements(let items):
            return items.map({$0.description}).joined(separator: ",")
            
        case .inlineMathFragments(let fragments):
            return fragments.map({$0.description}).joined(separator: ",")
        }
    }
}

@objc open class ResolvedResult: NSObject, DictionaryRepresentable, ElementRepresentable {
    public let resolvable: Resolvable
    public let result: Result
    
    public init(resolvable:Resolvable, result:Result) {
        self.resolvable = resolvable
        self.result = result
    }
    
    open var dictionaryRepresentation:[String:Any] {
        switch self.result {
        case .none:
            return ["type":"None" as AnyObject, "resolvable":resolvable.identifier as AnyObject, "value":[:]]
            
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
            
            return ["type":label as AnyObject,
                    "resolvable":resolvable.identifier as AnyObject,
                    "value":dictRep.dictionaryRepresentation as AnyObject]
        }
    }
    
    open func elementRepresentation() throws -> Element {
        let htmlReps = self.result.HTMLSnippetRepresentables
        
        if let firstRep = htmlReps.first, htmlReps.count == 1 {
            return try element(HTMLSnippet: firstRep.HTMLSnippetRepresentation)
        }
        
        let contents = htmlReps.map { $0.HTMLSnippetRepresentation }
        return try element(tagName: "div", contents: contents.joined(separator: ""))
    }
    
    open override var description: String {
        return "<ResolvedResult with Resolvable:\(resolvable), result:\(result)>"
    }
}
