//
//  FragmentProcessor.swift
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
