//
//  DocumentProcessor.swift
//  Extensions
//
//  Created by Matias Piipari on 22/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

public let MPDefaultXMLDocumentParsingOptions:Int =
                NSXMLNodeOptions.NodeLoadExternalEntitiesNever
                    .union(NSXMLNodeOptions.NodePreserveNamespaceOrder)
                    .union(NSXMLNodeOptions.NodePreserveAttributeOrder)
                    .union(NSXMLNodeOptions.NodePreserveEntities)
                    .union(NSXMLNodeOptions.NodePreservePrefixes)
                    .union(NSXMLNodeOptions.NodePreserveCDATA)
                    .union(NSXMLNodeOptions.NodePreserveWhitespace)
                    .union(NSXMLNodeOptions.NodePromoteSignificantWhitespace)
                    .union(NSXMLNodeOptions.NodePreserveEmptyElements)
                    .union(NSXMLNodeOptions.NodeUseDoubleQuotes).rawValue

public let MPDefaultXMLDocumentOutputOptions:Int =
                NSXMLNodeOptions.NodePreserveNamespaceOrder
                    .union(NSXMLNodeOptions.NodePreserveAttributeOrder)
                    .union(NSXMLNodeOptions.NodePreserveEntities)
                    .union(NSXMLNodeOptions.NodePreservePrefixes)
                    .union(NSXMLNodeOptions.NodePreserveCDATA)
                    .union(NSXMLNodeOptions.NodePreserveWhitespace)
                    .union(NSXMLNodeOptions.NodePromoteSignificantWhitespace)
                    .union(NSXMLNodeOptions.NodePreserveEmptyElements)
                    .union(NSXMLNodeOptions.NodeUseDoubleQuotes).rawValue

public class DocumentProcessorConstants {
    static func defaultXMLDocumentParsingOptions() -> UInt { return MPDefaultXMLDocumentParsingOptions }
    static func defaultXMLDocumentOutputOptions() -> UInt { return MPDefaultXMLDocumentOutputOptions }
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
        return try processedDocument(inputDocument: doc, inPlace:false).XMLStringWithOptions(Int(MPDefaultXMLDocumentOutputOptions))
    }
    
}
