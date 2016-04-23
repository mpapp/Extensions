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
    
    public var tokenizingPatterns: [String] {
        return ["\\s+"]
    }
    
    public var producesNodesForReplacedResults: Bool {
        return false
    }
    
    init(resolver:Resolver) {
        self.resolver = resolver
    }
    
    public func process(textFragment fragment: String) throws -> String {
        let result:ResolvedResult = try self.process(textFragment: fragment)
        
        let data = try NSJSONSerialization.dataWithJSONObject(result.dictionaryRepresentation(), options: [])
        guard let str = String(data: data, encoding: NSUTF8StringEncoding) else {
            throw DocumentProcessorError.FailedToRepresentDataInUTF8(data)
        }
        
        return str
    }
    
    public func process(textFragment fragment: String) throws -> ResolvedResult {
        return try resolver.resolve(fragment)
    }
}

public typealias ResolvedResultHandler = (textNode:NSXMLNode, fragment:String, resolvedResult:ResolvedResult) -> Void

// The resolvable element processor is a special kind of processor which never modifies the DOM.
// Instead it calls the `resolvableResultHandler` passed to it, for every case a resolvable identifier was found.
public struct ResolvableElementProcessor: ElementProcessor {
    
    let resolver:Resolver
    let fragmentProcessor:ResolvableFragmentProcessor
    let resolvedResultHandler: ResolvedResultHandler
    
    public init(resolver:Resolver, resolvedResultHandler:ResolvedResultHandler) {
        self.resolver = resolver
        self.fragmentProcessor = ResolvableFragmentProcessor(resolver: self.resolver)
        self.resolvedResultHandler = resolvedResultHandler
    }
    
    public var XPathPattern:String = {
        return "//p|//caption"
    }()
    
    public func process(element element:NSXMLElement, inDocument doc:NSXMLDocument) throws -> [NSXMLNode] {
        
        guard let children = element.children else {
            return [element]
        }
        
        for c in children {
            guard let stringValue = c.stringValue else {
                continue
            }
            
            do {
                let resolvable:ResolvedResult = try self.fragmentProcessor.process(textFragment: stringValue)
                self.resolvedResultHandler(textNode:c, fragment: stringValue, resolvedResult: resolvable)
            }
            catch ResolvingError.NotResolvable(_) {
                // specifically, don't log these errors.
                // print("\(fp) failed to resolve: \(str)")
            }
            catch {
                print("\(self.fragmentProcessor) failed to resolve: \(error)")
            }
        }
        
        return [element]
    }
}

public struct ResolvingDocumentProcessor: DocumentProcessor {
    
    public let resolver:Resolver
    public let elementProcessors:[ElementProcessor]
    
    public init(resolver:Resolver, elementProcessors:[ResolvableElementProcessor]) {
        self.resolver = resolver
        self.elementProcessors = elementProcessors.map { $0 }
    }
    
    public func processedDocument(inputDocument doc:NSXMLDocument) throws -> NSXMLDocument {
        let outputDoc:NSXMLDocument = doc.copy() as! NSXMLDocument
        
        for p in elementProcessors {
            try p.process(document: outputDoc)
        }
        
        return outputDoc
    }
    
    public func processedDocumentString(inputDocumentString docString:NSString) throws -> NSString {
        guard let docData = docString.dataUsingEncoding(NSUTF8StringEncoding) else {
            throw DocumentProcessorError.FailedToRepresentStringAsData(docString)
        }
        return try processedDocument(inputDocument: try NSXMLDocument(data: docData, options: Int(MPDefaultXMLDocumentParsingOptions))).XMLStringWithOptions(MPDefaultXMLDocumentOutputOptions)
    }
}