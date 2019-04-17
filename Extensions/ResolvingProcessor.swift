//
//  PDBIDProcessor.swift
//  Extensions
//
//  Created by Matias Piipari on 20/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

public enum ResolvingProcessorError: Error {
    case overlappingRanges(CountableClosedRange<UInt>, CountableClosedRange<UInt>)
}

// The resolvable fragment processor is a special kind of processor which never modifies the DOM.

public struct ResolvableFragmentProcessor: FragmentProcessor {
    
    fileprivate let resolver:Resolver
    
    //public let tokenizingPatterns: [String]
    public let capturingPatterns: [String]
    
    public var producesNodesForReplacedResults: Bool {
        return false
    }
    
    init(resolver:Resolver, tokenizingPatterns:[String], capturingPatterns:[String]) {
        self.resolver = resolver
        //self.tokenizingPatterns = tokenizingPatterns
        self.capturingPatterns = capturingPatterns
    }
    
    public func process(textFragment fragment: String) throws -> String {
        let result:ResolvedResult = try self.process(textFragment: fragment)
        
        let data = try JSONSerialization.data(withJSONObject: result.dictionaryRepresentation, options: [])
        guard let str = String(data: data, encoding: String.Encoding.utf8) else {
            throw DocumentProcessorError.failedToRepresentDataInUTF8(data)
        }
        
        return str
    }
    
    public func process(textFragment fragment: String) throws -> ResolvedResult {
        return try resolver.resolve(fragment)
    }
}

public typealias CapturedResultRange = (ranges:[Range<String.Index>], result:ResolvedResult)

public typealias ResolvedResultHandler = (_ elementProcessor:ResolvableElementProcessor, _ capturedResultRanges:[CapturedResultRange]) -> Void

public typealias ElementRepresentationProvider = (_ elementProcessor:ResolvableElementProcessor, _ capturedResultRange:CapturedResultRange, _ textNode:XMLNode) throws -> Element

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
    
    public func process(element:XMLElement, inDocument doc:XMLDocument) throws -> [XMLNode] {
        return try self.process(element: element, inDocument: doc, resultHandler: nil, elementRepresentationProvider: nil)
    }
    
    public func process(document doc:XMLDocument) throws -> [XMLNode] {
        return try self.process(document: doc, resultHandler: nil, elementRepresentationProvider: nil)
    }
    
    public func process(document doc:XMLDocument, resultHandler:ResolvedResultHandler?, elementRepresentationProvider:ElementRepresentationProvider? = nil) throws -> [XMLNode] {
        var processed = [XMLNode]()
        
        let nodes = try doc.nodes(forXPath: self.XPathPattern)
        
        for node in nodes {
            
            guard let elem = node as? XMLElement else {
                throw DocumentProcessorError.unexpectedNodeType(node)
            }
            
            let nodes = try self.process(element: elem, inDocument: doc, resultHandler: resultHandler, elementRepresentationProvider:elementRepresentationProvider)
            
            processed.append(contentsOf: nodes)
            
            // if element was modified in place, continue as you don't need to replace it.
            if (nodes.count == 1) && (nodes[0] === node) {
                continue
            }
            
            guard let parentNode = node.parent as? XMLElement else {
                throw DocumentProcessorError.unexpectedParentNode(node)
            }
            
            guard let nodeIndex = parentNode.children?.firstIndex(of: node) else {
                throw DocumentProcessorError.unexpectedParentNode(node)
            }
            
            parentNode.removeChild(at: nodeIndex)
            for (i,n) in nodes.reversed().enumerated() {
                parentNode.insertChild(n, at: nodeIndex)
                if let separator = self.separator, i < (nodes.count - 1) {
                    let separatorNode = XMLNode(kind: .text)
                    separatorNode.setStringValue(separator, resolvingEntities: false)
                    parentNode.insertChild(separatorNode, at: i + 1)
                }
            }
        }
        
        return processed
    }
    
    public func process(element:XMLElement, inDocument doc:XMLDocument, resultHandler:ResolvedResultHandler?, elementRepresentationProvider:ElementRepresentationProvider? = nil) throws -> [XMLNode] {
        guard let children = element.children else {
            return [element]
        }
        
        for c in children {
            if c.kind != .text {
                continue
            }
            
            guard let stringValue = c.stringValue else {
                continue
            }
            
            let capturedRanges = stringValue.capturedCharacterIndexRanges(capturingPatterns: self.fragmentProcessor.capturingPatterns)
            
            try capturedRanges.forEachPair { a, b in
                if a.overlaps(b) {
                    throw ResolvingProcessorError.overlappingRanges(a, b)
                }
            }
            
            let capturedResultRanges:[CapturedResultRange] = try capturedRanges.compactMap { range in
                
                let capture = stringValue[characterViewRange(range, string:stringValue)]
                let captureString = String(capture)
                
                do {
                    let result:ResolvedResult = try self.fragmentProcessor.process(textFragment: captureString)
                    let identifierRanges = captureString.ranges(result.resolvable.originatingString)
                    
                    let adjustedRanges = identifierRanges.map { identifierRange -> Range<String.Index> in
                        
                        let captureStartToIdentifierStart = capture.distance(from: capture.startIndex, to: identifierRange.lowerBound)
                        let captureStartToIdentifierEnd = capture.distance(from: capture.startIndex, to: identifierRange.upperBound)
                        
                        let start = stringValue.index(stringValue.index(stringValue.startIndex, offsetBy: captureStartToIdentifierStart),
                                                      offsetBy: Int(range.lowerBound))
                        let end = stringValue.index(stringValue.index(stringValue.startIndex, offsetBy: captureStartToIdentifierEnd),
                                                    offsetBy: Int(range.lowerBound))
                        return start ..< end
                    }
                    
                    return (ranges:adjustedRanges, result:result)
                }
                catch ResolvingError.notResolvable(let string) {
                    print("\(self) failed to resolve \(string)")
                    return nil
                }
                catch {
                    throw error
                }
            }
            
            if capturedResultRanges.count > 0 {
                resultHandler?(self, capturedResultRanges)
            }
            
            if self.replaceMatches && self.resolver.replaceMatches && capturedResultRanges.count > 0 {
                let elemReps:[Element]
                if let elementRepresentationProvider = elementRepresentationProvider {
                    elemReps = try capturedResultRanges.map {
                        try elementRepresentationProvider(self, $0, c)
                    }
                }
                else {
                    elemReps = try capturedResultRanges.map { try $0.result.elementRepresentation() }
                }
                let tagNames = elemReps.map { $0.tagName }
                let contents = elemReps.map { $0.contents }
                let attribs = elemReps.map { $0.attributes }
                
                let ranges = capturedResultRanges.flatMap { resultRange in
                    return resultRange.ranges
                }
                
                let stringRanges = ranges.map { range -> CountableRange<UInt> in
                    let start = stringValue.distance(from: stringValue.startIndex, to: range.lowerBound)
                    let end = stringValue.distance(from: stringValue.startIndex, to: range.upperBound)
                    return UInt(start) ..< UInt(end)
                }
                
                _ = c.extract(elementsWithNames:tagNames, ranges: stringRanges, contents: contents, attributes:attribs)
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
    
    public func processedDocument(inputDocument doc: XMLDocument, inPlace: Bool, resultHandler:ResolvedResultHandler?, elementRepresentationProvider:ElementRepresentationProvider? = nil) throws -> XMLDocument {
        let outputDoc:XMLDocument = inPlace ? doc : doc.copy() as! XMLDocument
        
        for elemProcessor in self.resolvableElementProcessors {
            _ = try elemProcessor.process(document: doc, resultHandler: resultHandler, elementRepresentationProvider: elementRepresentationProvider)
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
        
        let docProcessors = resolvers.enumerated().map { i, resolver in
            return ResolvingDocumentProcessor(resolver: resolvers[i], elementProcessors: [elemProcessors[i]])
        }
        
        self.documentProcessors = docProcessors
    }
    
    public func processedDocument(inputDocument doc: XMLDocument, inPlace: Bool, resultHandler:@escaping ResolvedResultHandler, elementRepresentationProvider:ElementRepresentationProvider? = nil) throws -> XMLDocument {
        let outputDoc:XMLDocument = inPlace ? doc : doc.copy() as! XMLDocument
        
        for docProcessor in self.documentProcessors {
            _ = try docProcessor.processedDocument(inputDocument: doc, inPlace: true, resultHandler: resultHandler, elementRepresentationProvider: elementRepresentationProvider)
        }
        
        return outputDoc
    }
}
