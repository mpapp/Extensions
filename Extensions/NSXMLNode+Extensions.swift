//
//  NSXMLElement+Extensions.swift
//  Extensions
//
//  Created by Matias Piipari on 11/05/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

extension NSXMLNode {
    
    public func split(atIndex index:UInt) -> (NSXMLNode, NSXMLNode) {
        precondition(self.kind == .TextKind, "Attempting to split an unexpected kind of node: \(self.kind) (\(self))")
        
        guard let stringValue = self.stringValue else {
            preconditionFailure("Node \(self) has no string value and cannot be split at \(index)")
        }
        
        let splitIndex = stringValue.startIndex.advancedBy(Int(index))
        
        let firstPartStr = stringValue.substringToIndex(splitIndex)
        let firstPartNode = NSXMLNode(kind: .TextKind)
        firstPartNode.stringValue = firstPartStr
        
        let secondPartStr = stringValue.substringFromIndex(splitIndex)
        let secondPartNode = NSXMLNode(kind: .TextKind)
        secondPartNode.stringValue = secondPartStr
        
        if let parentElem = self.parent as? NSXMLElement, let nodeIndex = parentElem.children?.indexOf(self) {
            parentElem.removeChildAtIndex(nodeIndex)
            parentElem.insertChild(secondPartNode, atIndex: nodeIndex)
            parentElem.insertChild(firstPartNode, atIndex: nodeIndex)
        }
        
        return (firstPartNode, secondPartNode)
    }
   
    public func split(atIndices indices:[UInt]) -> [NSXMLNode] {
        if indices.count == 0 {
            return [self]
        }
        
        var advance:Int = 0
        let lastIndex = indices.count - 1
        var currentSplit = self
        
        let splitNodes = indices.enumerate().flatMap { i, splitIndex -> [NSXMLNode] in
            let adjustedIndex = Int(splitIndex) - advance
            precondition(adjustedIndex >= 0)
            
            //if let charCount = self.stringValue?.characters.count where charCount == adjustedIndex {
            //    return []
            //}
            
            let splitNodes = currentSplit.split(atIndex: UInt(adjustedIndex))
            
            advance += splitNodes.0.stringValue!.characters.count
            currentSplit = splitNodes.1
            
            // First element is always added to output.
            // Second element from a split is added only on last split.
            let emitted = i < lastIndex ? [splitNodes.0] : [splitNodes.0, splitNodes.1]
            
            return emitted
        }
        
        return splitNodes
    }
    
    public func extract(elementWithName elementName:String, range:Range<UInt>) -> (before:NSXMLNode, extracted:NSXMLElement, after:NSXMLNode) {
        let split = self.split(atIndices: [range.startIndex, range.endIndex])
        precondition(split.count == 3, "Unexpected split: \(split)")
        
        let extractedNode = split[1]
        guard let parent = extractedNode.parent as? NSXMLElement else {
            preconditionFailure("Parent of \(extractedNode) is expected to be an element: \(extractedNode.parent)")
        }
        
        let str = extractedNode.XMLStringWithOptions(MPDefaultXMLDocumentParsingOptions)
        let elem = NSXMLElement(name: elementName, stringValue: str)
        parent.replace(extractedNode, withNodes: [elem])
        
        return (split[0], elem, split[2])
    }
    
    public func extract(elementsWithName elementName:String, ranges:[Range<UInt>]) -> [NSXMLNode] {
        return self.extract(elementsWithNames:(0..<ranges.count).map { _ in elementName }, ranges:ranges)
    }
    
    public func extract(elementsWithNames elementNames:[String], ranges:[Range<UInt>]) -> [NSXMLNode] {
        for ra in ranges {
            for rb in ranges {
                if ra == rb { continue }
                precondition(!ra.overlaps(rb), "Range \(ra) overlaps with range \(rb)")
            }
        }
        
        if ranges.count == 0 {
            return [self]
        }
        
        var advance:Int = 0
        let lastIndex = ranges.count - 1
        var currentSplit = self
        
        let splitNodes = ranges.enumerate().flatMap { i, splitRange -> [NSXMLNode] in
            let adjustedStartIndex = Int(splitRange.startIndex) - advance
            let adjustedEndIndex = Int(splitRange.endIndex) - advance
            let adjustedRange = UInt(adjustedStartIndex) ..< UInt(adjustedEndIndex)
            precondition(splitRange.count == adjustedRange.count)
            
            let splitNodes = currentSplit.extract(elementWithName:elementNames[i], range:adjustedRange)
            
            let advanceBefore = advance
            
            advance += Int(adjustedRange.endIndex)
            
            currentSplit = splitNodes.after
            
            // First element is always added to output.
            // Second element from a split is added only on last split.
            let emitted = i < lastIndex ? [splitNodes.before, splitNodes.extracted] : [splitNodes.before, splitNodes.extracted, splitNodes.after]
            
            print("advance:\(advance) before:\(advanceBefore) emitted:\(emitted) range:\(adjustedRange) remainder:\(currentSplit.stringValue)")
            
            return emitted
        }
        
        
        return splitNodes
    }
}

extension NSXMLElement {
    
    public func replace(child:NSXMLNode, withNodes:[NSXMLNode]) -> Int {
        let iOpt = self.children?.indexOf(child)
        
        guard let i = iOpt else {
            preconditionFailure("Cannot find \(child) amongst children of \(self)")
        }
        
        self.removeChildAtIndex(i)
        
        for j in 0 ..< withNodes.count {
            let n:NSXMLNode = withNodes[j]
            n.detach()
            self.insertChild(n, atIndex: i+j)
        }
        
        return i
    }
}