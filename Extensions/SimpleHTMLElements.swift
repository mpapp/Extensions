//
//  InlineHTMLElement.swift
//  Extensions
//
//  Created by Matias Piipari on 24/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

enum ElementError:Error {
    case unexpectedTagName(String)
    case unexpectedSnippet(String)
}

open class SimpleInlineElement: NSObject, InlineElement {
    open let contents: String
    open let tagName: String
    open let attributes: [String:String]
    
    public init(contents:String, tagName:String = "span", attributes:[String:String] = [:]) {
        self.contents = contents
        self.tagName = tagName
        self.attributes = attributes
    }
    
    open class var tagName: String {
        return "span"
    }
    
    open override var description: String {
        return "<\(String(describing: type(of: self))) tagName:\(tagName) contents:\(contents)>"
    }
}

open class SimpleBlockElement: NSObject, BlockElement {
    open let contents: String
    open let tagName: String
    open let attributes: [String : String]
    
    public init(contents:String, tagName:String = "div", attributes: [String : String] = [:]) {
        self.contents = contents
        self.tagName = tagName
        self.attributes = attributes
    }
    
    open override var description: String {
        return "<\(String(describing: type(of: self))) tagName:\(tagName) contents:\(contents)>"
    }
}

func element(tagName:String, contents:String, attributes:[String:String] = [:]) throws -> Element {
    let lowercaseTagName = tagName.lowercased()

    switch lowercaseTagName {
    case "p", "div":
        return SimpleBlockElement(contents: contents, tagName: tagName, attributes: attributes)
        
    case "span", "strong", "em", "i", "b":
        return SimpleInlineElement(contents: contents, tagName: tagName, attributes: attributes)
        
    default:
        throw ElementError.unexpectedTagName(tagName)
    }
}

func element(HTMLSnippet snippet:String) throws -> Element {
    let doc = try XMLDocument(xmlString: snippet, options: Extensions.defaultXMLDocumentParsingOptions)
    
    if let root = doc.rootElement(), let rootTagName = root.name, let children = root.children {
        
        var attribs = [String:String]()
        for key in root.attributeKeys {
            if let value = root.attribute(forName: key)?.stringValue {
                attribs[key] = value
            }
        }
        
        let str = children.map {
            return $0.xmlString(options: Extensions.defaultXMLDocumentOutputOptions)
        }.joined(separator: "")
        
        return try element(tagName:rootTagName, contents:str, attributes: attribs)
    }
    
    throw ElementError.unexpectedSnippet(snippet)
}
