//
//  ElementProcessor.swift
//  Extensions
//
//  Created by Matias Piipari on 22/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

public protocol ElementProcessor {
    var XPathPattern:String { get }
    var separator:String? { get }
    var replaceMatches:Bool { get }
    
    func process(element element:NSXMLElement, inDocument doc:NSXMLDocument) throws -> [NSXMLNode]
    
    func process(document doc:NSXMLDocument) throws -> [NSXMLNode]
}

typealias ProcessedNodeHandler = () -> Void

extension ElementProcessor {
    
    public var separator:String? { return ";" }
    
    public func process(document doc:NSXMLDocument) throws -> [NSXMLNode] {
        var processed = [NSXMLNode]()
        
        let nodes = try doc.nodesForXPath(self.XPathPattern)
        
        for node in nodes {
            
            guard let elem = node as? NSXMLElement else {
                throw DocumentProcessorError.UnexpectedNodeType(node)
            }
            
            let nodes = try self.process(element: elem, inDocument: doc)
            
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
}
