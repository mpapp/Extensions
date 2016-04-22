//
//  DocumentProcessor.swift
//  Extensions
//
//  Created by Matias Piipari on 22/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

let MPDefaultXMLDocumentParsingOptions:Int =
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

let MPDefaultXMLDocumentOutputOptions:Int =
    NSXMLNodePreserveNamespaceOrder |
    NSXMLNodePreserveAttributeOrder |
    NSXMLNodePreserveEntities |
    NSXMLNodePreservePrefixes |
    NSXMLNodePreserveCDATA |
    NSXMLNodePreserveWhitespace |
    NSXMLNodePromoteSignificantWhitespace |
    NSXMLNodePreserveEmptyElements |
    NSXMLNodeUseDoubleQuotes

public protocol DocumentProcessor {
    
    var elementProcessors:[ElementProcessor] { get }
    
    func processedDocument(inputDocument doc:NSXMLDocument) throws -> NSXMLDocument
    
    func processedDocumentString(inputDocumentString docString:NSString) throws -> NSString
}


public extension DocumentProcessor {
    
    func processedDocument(inputDocument doc:NSXMLDocument) throws -> NSXMLDocument {
        let outputDoc:NSXMLDocument = doc.copy() as! NSXMLDocument
        
        for processor in self.elementProcessors {
            try processor.process(document: outputDoc)
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
