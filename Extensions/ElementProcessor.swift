//
//  ElementProcessor.swift
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

public protocol ElementProcessor {
    var XPathPattern:String { get }
    var separator:String? { get }
    var replaceMatches:Bool { get }
    
    func process(element:XMLElement, inDocument doc:XMLDocument) throws -> [XMLNode]
    
    func process(document doc:XMLDocument) throws -> [XMLNode]
}

typealias ProcessedNodeHandler = () -> Void

extension ElementProcessor {
    
    public var separator:String? { return ";" }
    
    public func process(document doc:XMLDocument) throws -> [XMLNode] {
        var processed = [XMLNode]()
        
        let nodes = try doc.nodes(forXPath: self.XPathPattern)
        
        for node in nodes {
            
            guard let elem = node as? XMLElement else {
                throw DocumentProcessorError.unexpectedNodeType(node)
            }
            
            let nodes = try self.process(element: elem, inDocument: doc)
            
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
}
