//
//  DocumentProcessor.swift
//  Extensions
//
//  Created by Matias Piipari on 22/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//
//  ---------------------------------------------------------------------------
//
//  © 2019 Atypon Systems LLC
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import Foundation

public let defaultXMLDocumentParsingOptions =
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

public let defaultXMLDocumentOutputOptions =
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
    static func defaultXMLDocumentParsingOptions() -> XMLNode.Options { return Extensions.defaultXMLDocumentParsingOptions }
    static func defaultXMLDocumentOutputOptions() -> XMLNode.Options { return Extensions.defaultXMLDocumentOutputOptions }
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
    
    func processedDocumentString(inputDocumentString docString: String) throws -> String {
        guard let docData = docString.data(using: .utf8) else {
            throw DocumentProcessorError.failedToRepresentStringAsData(docString)
        }
        
        let doc = try XMLDocument(data: docData, options: Extensions.defaultXMLDocumentParsingOptions)
        let processedDoc = try processedDocument(inputDocument: doc, inPlace:false)

        return processedDoc.xmlString(options: Extensions.defaultXMLDocumentOutputOptions)
    }
    
}
