//
//  FragmentProcessor.swift
//  Extensions
//
//  Created by Matias Piipari on 22/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

public protocol FragmentProcessor {
    func process(textNode node:XMLNode) throws -> [XMLNode]
    func processedResult(_ textNode:XMLNode, output:String) -> Void
    
    // Overload these methods.
    
    //var tokenizingPatterns:[String] { get }
    var capturingPatterns:[String] { get }
    var producesNodesForReplacedResults:Bool { get }
    
    func process(textFragment fragment:String) throws -> String
}

public extension FragmentProcessor {
    func process(textNode node:XMLNode) throws -> [XMLNode] {
        
        guard let stringValue = node.stringValue else {
            return [node]
        }
        
        let captured = stringValue.componentsCaptured(capturingPatterns: self.capturingPatterns)
        
        let fragments:[String] = try captured.map { (c:String) in
            let result = try self.process(textFragment: c)
            self.processedResult(node, output: result)
            return result
        }
        
        if self.producesNodesForReplacedResults {
            let fragmentNodes = fragments.map { (str:String) -> XMLNode in
                let newNode = XMLNode(kind: .text)
                newNode.setStringValue(str, resolvingEntities: false)
                
                return newNode
            }
            
            return fragmentNodes
        }
        
        return [node]
    }
    
    func processedResult(_ textNode:XMLNode, output:String) -> Void {
        // Overload at will.
    }
}
