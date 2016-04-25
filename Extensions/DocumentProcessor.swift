//
//  DocumentProcessor.swift
//  Extensions
//
//  Created by Matias Piipari on 22/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

public let MPDefaultXMLDocumentParsingOptions:Int =
    NSXMLNodeLoadExternalEntitiesNever |
    NSXMLNodePreserveNamespaceOrder |
    NSXMLNodePreserveAttributeOrder |
    NSXMLNodePreserveEntities |
    NSXMLNodePreservePrefixes |
    NSXMLNodePreserveCDATA |
    NSXMLNodePreserveWhitespace |
    NSXMLNodePromoteSignificantWhitespace |
    NSXMLNodePreserveEmptyElements |
    NSXMLNodeUseDoubleQuotes

public let MPDefaultXMLDocumentOutputOptions:Int =
    NSXMLNodePreserveNamespaceOrder |
    NSXMLNodePreserveAttributeOrder |
    NSXMLNodePreserveEntities |
    NSXMLNodePreservePrefixes |
    NSXMLNodePreserveCDATA |
    NSXMLNodePreserveWhitespace |
    NSXMLNodePromoteSignificantWhitespace |
    NSXMLNodePreserveEmptyElements |
    NSXMLNodeUseDoubleQuotes

@objc public class DocumentProcessorConstants: NSObject {
    static func defaultXMLDocumentParsingOptions() -> Int { return MPDefaultXMLDocumentParsingOptions }
    static func defaultXMLDocumentOutputOptions() -> Int { return MPDefaultXMLDocumentOutputOptions }
}

public protocol DocumentProcessor {
    
    var elementProcessors:[ElementProcessor] { get }
    
    func processedDocument(inputDocument doc:NSXMLDocument, inPlace:Bool) throws -> NSXMLDocument
    
    func processedDocumentString(inputDocumentString docString:NSString) throws -> NSString
}


public extension DocumentProcessor {
    
    func processedDocument(inputDocument doc:NSXMLDocument, inPlace:Bool = false) throws -> NSXMLDocument {
        let outputDoc:NSXMLDocument = inPlace ? doc : doc.copy() as! NSXMLDocument
        
        for processor in self.elementProcessors {
            try processor.process(document: outputDoc)
        }
        
        return outputDoc
    }
    
    public func processedDocumentString(inputDocumentString docString:NSString) throws -> NSString {
        guard let docData = docString.dataUsingEncoding(NSUTF8StringEncoding) else {
            throw DocumentProcessorError.FailedToRepresentStringAsData(docString)
        }
        
        let doc = try NSXMLDocument(data: docData, options: Int(MPDefaultXMLDocumentParsingOptions))
        return try processedDocument(inputDocument: doc, inPlace:false).XMLStringWithOptions(MPDefaultXMLDocumentOutputOptions)
    }
    
}
