//
//  PDBIDProcessor.swift
//  Extensions
//
//  Created by Matias Piipari on 20/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

// The resolvable fragment processor is a special kind of processor which never modifies the DOM.

public struct ResolvableFragmentProcessor: FragmentProcessor {
    
    private let resolver:Resolver
    
    public let tokenizingPatterns: [String]
    public let capturingPatterns: [String]
    
    public var producesNodesForReplacedResults: Bool {
        return false
    }
    
    init(resolver:Resolver, tokenizingPatterns:[String], capturingPatterns:[String]) {
        self.resolver = resolver
        self.tokenizingPatterns = tokenizingPatterns
        self.capturingPatterns = capturingPatterns
    }
    
    public func process(textFragment fragment: String) throws -> String {
        let result:ResolvedResult = try self.process(textFragment: fragment)
        
        let data = try NSJSONSerialization.dataWithJSONObject(result.dictionaryRepresentation, options: [])
        guard let str = String(data: data, encoding: NSUTF8StringEncoding) else {
            throw DocumentProcessorError.FailedToRepresentDataInUTF8(data)
        }
        
        return str
    }
    
    public func process(textFragment fragment: String) throws -> ResolvedResult {
        return try resolver.resolve(fragment)
    }
}

public typealias ResolvedResultHandler = (elementProcessor:ResolvableElementProcessor, textNode:NSXMLNode, fragment:String, resolvedResult:ResolvedResult) -> Void

// The resolvable element processor is a special kind of processor which never modifies the DOM.
// Instead it calls the `resolvableResultHandler` passed to it, for every case a resolvable identifier was found.
public struct ResolvableElementProcessor: ElementProcessor {
    
    let resolver:Resolver
    public let replaceMatches: Bool
    let fragmentProcessor:ResolvableFragmentProcessor
    
    public init(resolver:Resolver, tokenizingPatterns:[String], capturingPatterns:[String], replaceMatches:Bool = false) {
        self.resolver = resolver
        self.replaceMatches = replaceMatches
        self.fragmentProcessor = ResolvableFragmentProcessor(resolver: self.resolver, tokenizingPatterns: tokenizingPatterns, capturingPatterns: capturingPatterns)
    }
    
    public var XPathPattern:String = {
        return "//p|//caption"
    }()
    
    public func process(element element:NSXMLElement, inDocument doc:NSXMLDocument) throws -> [NSXMLNode] {
        return try self.process(element: element, inDocument: doc, resultHandler: nil)
    }
    
    public func process(document doc:NSXMLDocument) throws -> [NSXMLNode] {
        return try self.process(document: doc, resultHandler: nil)
    }
    
    public func process(document doc:NSXMLDocument, resultHandler:ResolvedResultHandler?) throws -> [NSXMLNode] {
        var processed = [NSXMLNode]()
        
        let nodes = try doc.nodesForXPath(self.XPathPattern)
        
        for node in nodes {
            
            guard let elem = node as? NSXMLElement else {
                throw DocumentProcessorError.UnexpectedNodeType(node)
            }
            
            let nodes = try self.process(element: elem, inDocument: doc, resultHandler: resultHandler)
            
            processed.appendContentsOf(nodes)
            
            // if element was modified in place, continue as you don't need to replace it.
            if (nodes.count == 1) && (nodes[0] === node) {
                continue
            }
            
            guard let parentNode = node.parent as? NSXMLElement else {
                throw DocumentProcessorError.UnexpectedParentNode(node)
            }
            
            guard let nodeIndex = parentNode.children?.indexOf(node) else {
                throw DocumentProcessorError.UnexpectedParentNode(node)
            }
            
            parentNode.removeChildAtIndex(nodeIndex)
            for (i,n) in nodes.reverse().enumerate() {
                parentNode.insertChild(n, atIndex: nodeIndex)
                if let separator = self.separator where i < (nodes.count - 1) {
                    let separatorNode = NSXMLNode(kind: .TextKind)
                    separatorNode.setStringValue(separator, resolvingEntities: false)
                    parentNode.insertChild(separatorNode, atIndex: i + 1)
                }
            }
        }
        
        return processed
    }
    
    public func process(element element:NSXMLElement, inDocument doc:NSXMLDocument, resultHandler:ResolvedResultHandler?) throws -> [NSXMLNode] {
        
        guard let children = element.children else {
            return [element]
        }
        
        for c in children {
            guard let stringValue = c.stringValue else {
                continue
            }
            
            let splitStrings = stringValue.componentsSeparated(tokenizingPatterns: self.fragmentProcessor.tokenizingPatterns)
            
            for splitStr in splitStrings {
                
                let captures = splitStr.componentsCaptured(capturingPatterns: self.fragmentProcessor.capturingPatterns)
                
                for capture in captures {
                    do {
                        let resolvable:ResolvedResult = try self.fragmentProcessor.process(textFragment: capture)
                        
                        if let str = c.stringValue where self.replaceMatches {
                            let htmlRep = try resolvable.elementRepresentation().HTMLSnippetRepresentation
                            let replacedStringValue = str.stringByReplacingOccurrencesOfString(resolvable.resolvable.identifier, withString: htmlRep)
                            
                            
                            //replacedStringValue.enumerateSubstringsInRange(<#T##range: Range<Index>##Range<Index>#>, options: <#T##NSStringEnumerationOptions#>, <#T##body: (substring: String?, substringRange: Range<Index>, enclosingRange: Range<Index>, inout Bool) -> ()##(substring: String?, substringRange: Range<Index>, enclosingRange: Range<Index>, inout Bool) -> ()#>)
                            //let doc = NSXMLElement(XMLString: "</p>\(replacedStringValue)<p>")
                            
                            c.stringValue = replacedStringValue
                        }
                        
                        if let resultHandler = resultHandler {
                            resultHandler(elementProcessor:self, textNode:c, fragment: splitStr, resolvedResult: resolvable)
                        }
                    }
                    catch ResolvingError.NotResolvable(_) {
                        // specifically, don't log these errors.
                        // print("\(fp) failed to resolve: \(str)")
                    }
                    catch {
                        print("\(self.fragmentProcessor) failed to resolve: \(error)")
                    }
                }
            }
        }
        
        return [element]
    }
}

public struct ResolvingDocumentProcessor: DocumentProcessor {
    
    public let resolver:Resolver
    public var elementProcessors:[ElementProcessor] {
        return self.resolvableElementProcessors.map { $0 }
    }
    public let resolvableElementProcessors:[ResolvableElementProcessor]
    
    public init(resolver:Resolver, elementProcessors:[ResolvableElementProcessor]) {
        self.resolver = resolver
        self.resolvableElementProcessors = elementProcessors.map { $0 }
    }
    
    public func processedDocument(inputDocument doc: NSXMLDocument, inPlace: Bool, resultHandler:ResolvedResultHandler?) throws -> NSXMLDocument {
        let outputDoc:NSXMLDocument = inPlace ? doc : doc.copy() as! NSXMLDocument
        
        for elemProcessor in self.resolvableElementProcessors {
            try elemProcessor.process(document: doc, resultHandler: resultHandler)
        }
        
        return outputDoc
    }
}

public struct ResolvingCompoundDocumentProcessor: DocumentProcessor {
    
    public let documentProcessors:[ResolvingDocumentProcessor]
    
    public var resolvableElementProcessors:[ResolvableElementProcessor] {
        return self.documentProcessors.flatMap { $0.resolvableElementProcessors }
    }
    
    public var elementProcessors: [ElementProcessor] {
        return self.documentProcessors.flatMap { $0.elementProcessors }
    }
    
    public init(resolvers:[Resolver], replaceMatches:Bool = false) {
        let elemProcessors = resolvers.map {
            ResolvableElementProcessor(
                resolver: $0,
                tokenizingPatterns: [],
                capturingPatterns: [$0.resolvableType.capturingPattern()],
                replaceMatches: replaceMatches)
        }
        
        let docProcessors = resolvers.enumerate().map { i, resolver in
            return ResolvingDocumentProcessor(resolver: resolvers[i], elementProcessors: [elemProcessors[i]])
        }
        
        self.documentProcessors = docProcessors
    }
    
    public func processedDocument(inputDocument doc: NSXMLDocument, inPlace: Bool, resultHandler:ResolvedResultHandler) throws -> NSXMLDocument {
        let outputDoc:NSXMLDocument = inPlace ? doc : doc.copy() as! NSXMLDocument
        
        for docProcessor in self.documentProcessors {
            try docProcessor.processedDocument(inputDocument: doc, inPlace: true, resultHandler: resultHandler)
        }
        
        return outputDoc
    }
}