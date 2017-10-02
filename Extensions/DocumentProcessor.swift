//
//  DocumentProcessor.swift
//  Extensions
//
//  Created by Matias Piipari on 22/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

public let MPDefaultXMLDocumentParsingOptions =
                XMLNode.Options.nodeLoadExternalEntitiesNever
                    .union(XMLNode.Options.nodePreserveNamespaceOrder)
                    .union(XMLNode.Options.nodePreserveAttributeOrder)
                    .union(XMLNode.Options.nodePreserveEntities)
                    .union(XMLNode.Options.nodePreservePrefixes)
                    .union(XMLNode.Options.nodePreserveCDATA)
                    .union(XMLNode.Options.nodePreserveWhitespace)
                    .union(XMLNode.Options.nodePromoteSignificantWhitespace)
                    .union(XMLNode.Options.nodePreserveEmptyElements)
                    .union(XMLNode.Options.nodeUseDoubleQuotes)

public let MPDefaultXMLDocumentOutputOptions =
                XMLNode.Options.nodePreserveNamespaceOrder
                    .union(XMLNode.Options.nodePreserveAttributeOrder)
                    .union(XMLNode.Options.nodePreserveEntities)
                    .union(XMLNode.Options.nodePreservePrefixes)
                    .union(XMLNode.Options.nodePreserveCDATA)
                    .union(XMLNode.Options.nodePreserveWhitespace)
                    .union(XMLNode.Options.nodePromoteSignificantWhitespace)
                    .union(XMLNode.Options.nodePreserveEmptyElements)
                    .union(XMLNode.Options.nodeUseDoubleQuotes)

open class DocumentProcessorConstants {
    static func defaultXMLDocumentParsingOptions() -> XMLNode.Options { return MPDefaultXMLDocumentParsingOptions }
    static func defaultXMLDocumentOutputOptions() -> XMLNode.Options { return MPDefaultXMLDocumentOutputOptions }
}

public protocol DocumentProcessor {
    
    var elementProcessors:[ElementProcessor] { get }
    
    func processedDocument(inputDocument doc:XMLDocument, inPlace:Bool) throws -> XMLDocument
    
    func processedDocumentString(inputDocumentString docString:String) throws -> String
}


public extension DocumentProcessor {
    
    func processedDocument(inputDocument doc:XMLDocument, inPlace:Bool = false) throws -> XMLDocument {
        let outputDoc:XMLDocument = inPlace ? doc : doc.copy() as! XMLDocument
        
        for processor in self.elementProcessors {
            _ = try processor.process(document: outputDoc)
        }
        
        return outputDoc
    }
    
    public func processedDocumentString(inputDocumentString docString:String) throws -> String {
        guard let docData = docString.data(using: .utf8) else {
            throw DocumentProcessorError.failedToRepresentStringAsData(docString)
        }
        
        let doc = try XMLDocument(data: docData, options: MPDefaultXMLDocumentParsingOptions)
        
        let processedDoc = try processedDocument(inputDocument: doc, inPlace:false)
        return processedDoc.xmlString(options: MPDefaultXMLDocumentOutputOptions)
    }
    
}
