//
//  PDBIDProcessor.swift
//  Extensions
//
//  Created by Matias Piipari on 20/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

public class ResolvableFragmentProcessor: FragmentProcessor {
    
    private let resolver:Resolver
    
    public var tokenizingPatterns: [String] {
        return ["\\s+"]
    }
    
    init(resolver:Resolver) {
        self.resolver = resolver
    }
    
    public func process(textFragment fragment: String) throws -> String {
        let result:ResolvableResult = try self.process(textFragment: fragment)
        
        let data = try NSJSONSerialization.dataWithJSONObject(result.dictionaryRepresentation(), options: [])
        guard let str = String(data: data, encoding: NSUTF8StringEncoding) else {
            throw DocumentProcessorError.FailedToRepresentDataInUTF8(data)
        }
        
        return str
    }
    
    public func process(textFragment fragment: String) throws -> ResolvableResult {
        return try resolver.resolve(fragment)
    }
}

typealias ResolvableResultHandler = (fragment:String, resolution:ResolvableResult) -> Void

// The resolvable element processor is a special kind of processor which never modifies the DOM.
// Instead it calls the `resolvableResultHandler` passed to it, for every case a resolvable identifier was found.
public struct ResolvableElementProcessor: ElementProcessor {
    
    let resolver:Resolver
    let fragmentProcessors:[ResolvableFragmentProcessor]
    let resolvableResultHandler: ResolvableResultHandler
    
    public var XPathPattern:String = {
        return "//p|//caption"
    }()
    
    public func process(element element:NSXMLElement, inDocument doc:NSXMLDocument) throws -> [NSXMLNode] {
        
        guard let children = element.children else {
            return [element]
        }
        
        for c in children {
            for fp in self.fragmentProcessors {
                guard let stringValue = c.stringValue else {
                    continue
                }
                
                do {
                    let resolvable:ResolvableResult = try fp.process(textFragment: stringValue)
                    self.resolvableResultHandler(fragment: stringValue, resolution: resolvable)
                }
                catch ResolvingError.NotResolvable(_) {
                    // specifically, don't log these errors.
                    // print("\(fp) failed to resolve: \(str)")
                }
                catch {
                    print("\(fp) failed to resolve: \(error)")
                }
            }
        }
        
        return [element]
    }
}

public struct ResolvableDocumentProcessor: DocumentProcessor {
    
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
        return try processedDocument(inputDocument: try NSXMLDocument(data: docData, options: Int(MPDefaultXMLDocumentParsingOptions))).XMLString
    }
}