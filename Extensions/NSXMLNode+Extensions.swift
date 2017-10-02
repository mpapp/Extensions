//
//  NSXMLElement+Extensions.swift
//  Extensions
//
//  Created by Matias Piipari on 11/05/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

extension XMLNode {
    
    public func split(atIndex index:UInt) -> (XMLNode, XMLNode) {
        precondition(self.kind == .text, "Attempting to split an unexpected kind of node: \(self.kind) (\(self))")
        
        guard let stringValue = self.stringValue else {
            preconditionFailure("Node \(self) has no string value and cannot be split at \(index)")
        }
        
        let splitIndex = stringValue.characters.index(stringValue.startIndex, offsetBy: Int(index))
        
        let firstPartStr = String(stringValue[..<splitIndex])
        let firstPartNode = XMLNode(kind: .text)
        firstPartNode.stringValue = firstPartStr
        
        let secondPartStr = String(stringValue[splitIndex...])
        let secondPartNode = XMLNode(kind: .text)
        secondPartNode.stringValue = secondPartStr
        
        if let parentElem = self.parent as? XMLElement, let nodeIndex = parentElem.children?.index(of: self) {
            parentElem.removeChild(at: nodeIndex)
            parentElem.insertChild(secondPartNode, at: nodeIndex)
            parentElem.insertChild(firstPartNode, at: nodeIndex)
        }
        
        return (firstPartNode, secondPartNode)
    }
   
    public func split(atIndices indices:[UInt]) -> [XMLNode] {
        if indices.count == 0 {
            return [self]
        }
        
        var advance:Int = 0
        let lastIndex = indices.count - 1
        var currentSplit = self
        
        let splitNodes = indices.enumerated().flatMap { i, splitIndex -> [XMLNode] in
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
    
    public func extract(elementWithName elementName:String,
                        range:CountableRange<UInt>,
                        contents:String? = nil,
                        attributes:[String:String]? = nil) -> (before:XMLNode, extracted:XMLElement, after:XMLNode) {
        let split = self.split(atIndices: [range.lowerBound, range.upperBound])
        precondition(split.count == 3, "Unexpected split: \(split)")
        
        let extractedNode = split[1]
        guard let parent = extractedNode.parent as? XMLElement else {
            preconditionFailure("Parent of \(extractedNode) is expected to be an element: \(extractedNode.parent?.xmlString ?? "nil")")
        }
        
        let str = extractedNode.xmlString(options: XMLNode.Options(rawValue: XMLNode.Options.RawValue(Int(MPDefaultXMLDocumentParsingOptions))))
        let elem = XMLElement(name: elementName, stringValue: contents ?? str)
        _ = parent.replace(extractedNode, withNodes: [elem])
        
        if let attributes = attributes {
            for (key, value) in attributes {
                let attribNode = XMLNode(kind: .attribute)
                attribNode.name = key
                attribNode.stringValue = value
                elem.addAttribute(attribNode)
            }            
        }
        
        return (split[0], elem, split[2])
    }
    
    public func extract(elementsWithName elementName:String, ranges:[CountableRange<UInt>], contents:[String]? = nil, attributes:[[String:String]]? = nil) -> [XMLNode] {
        return self.extract(elementsWithNames:(0..<ranges.count).map { _ in elementName }, ranges:ranges, contents:contents, attributes:attributes)
    }
    
    public func extract(elementsWithNames elementNames:[String],
                        ranges:[CountableRange<UInt>],
                        contents:[String]? = nil,
                        attributes:[[String:String]]? = nil) -> [XMLNode] {
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
        
        let splitNodes = ranges.enumerated().flatMap { i, splitRange -> [XMLNode] in
            let adjustedStartIndex = Int(splitRange.lowerBound) - advance
            let adjustedEndIndex = Int(splitRange.upperBound) - advance
            
            let adjustedRange = UInt(adjustedStartIndex) ..< UInt(adjustedEndIndex)
            
            precondition(splitRange.count == adjustedRange.count)
            
            let elemContents:String?
            if let contents = contents {
                elemContents = contents[i]
            }
            else {
                elemContents = nil
            }
            
            let attribs:[String:String]?
            if let attributes = attributes {
                attribs = attributes[i]
            }
            else {
                attribs = nil
            }
            
            
            let splitNodes = currentSplit.extract(elementWithName:elementNames[i],
                                                  range:adjustedRange,
                                                  contents:elemContents,
                                                  attributes: attribs)
            
            //let advanceBefore = advance
            
            advance += Int(adjustedRange.upperBound)
            
            currentSplit = splitNodes.after
            
            // First element is always added to output.
            // Second element from a split is added only on last split.
            let emitted = i < lastIndex ? [splitNodes.before, splitNodes.extracted] : [splitNodes.before, splitNodes.extracted, splitNodes.after]
            
            //print("advance:\(advance) before:\(advanceBefore) emitted:\(emitted) range:\(adjustedRange) remainder:\(currentSplit.stringValue)")
            
            return emitted
        }
        
        
        return splitNodes
    }
}

extension XMLElement {
    
    public func replace(_ child:XMLNode, withNodes:[XMLNode]) -> Int {
        let iOpt = self.children?.index(of: child)
        
        guard let i = iOpt else {
            preconditionFailure("Cannot find \(child) amongst children of \(self)")
        }
        
        self.removeChild(at: i)
        
        for j in 0 ..< withNodes.count {
            let n:XMLNode = withNodes[j]
            n.detach()
            self.insertChild(n, at: i+j)
        }
        
        return i
    }
}
