//
//  HTMLProcessable.swift
//  Manuscripts
//
//  Created by Matias Piipari on 17/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation
import Regex

public enum HTMLProcessableErrorType : ErrorType {
    case ReferenceIDAttributeMissing(NSXMLElement)
    case ReferenceUnresolvable(NSString)
    case UnexpectedParentNode(NSXMLNode?)
    case UnexpectedChildIndex(NSXMLNode)
    case FailedToRepresentStringAsData(NSString)
    case UnexpectedNodeType(NSXMLNode)
}

public protocol ElementProcessor {
    func XPathPattern() -> String
    var separator:String { get }
    
    func process(element element:NSXMLElement, inDocument doc:NSXMLDocument) throws -> [NSXMLNode]
}

public protocol FragmentProcessor {
    var capturingPattern:String { get }
    var tokenizingPattern:String { get }
    func process(node node:NSXMLNode) throws -> [NSXMLNode]
    func process(fragment fragment:String) throws -> [NSXMLNode]
}

extension FragmentProcessor {
    func process(node node:NSXMLNode) throws -> [NSXMLNode] {
        return [node]
    }
}

extension ElementProcessor {
    
    var separator:String { return ";" }
    
    public func process(document doc:NSXMLDocument) throws -> [NSXMLNode] {
        var processed = [NSXMLNode]()
        
        let nodes = try doc.nodesForXPath(self.XPathPattern())
        
        for node in nodes {
            
            guard let elem = node as? NSXMLElement else {
                throw HTMLProcessableErrorType.UnexpectedNodeType(node)
            }
            
            let nodes = try self.process(element: elem, inDocument: doc)
            
            processed.appendContentsOf(nodes)
            
            // if element was modified in place, continue as you don't need to replace it.
            if (nodes.count == 1) && (nodes[0] === node) {
                continue
            }
            
            guard let parentNode = node.parent as? NSXMLElement else {
                throw HTMLProcessableErrorType.UnexpectedParentNode(node)
            }
            
            guard let nodeIndex = parentNode.children?.indexOf(node) else {
                throw HTMLProcessableErrorType.UnexpectedParentNode(node)
            }
            
            parentNode.removeChildAtIndex(nodeIndex)
            for (i,n) in nodes.reverse().enumerate() {
                parentNode.insertChild(n, atIndex: nodeIndex)
                if (i < (nodes.count - 1)) {
                    let separatorNode = NSXMLNode(kind: .TextKind)
                    separatorNode.setStringValue(self.separator, resolvingEntities: false)
                    parentNode.insertChild(separatorNode, atIndex: i + 1)
                }
            }
        }
        
        return processed
    }
}
