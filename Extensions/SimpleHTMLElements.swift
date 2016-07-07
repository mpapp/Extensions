//
//  InlineHTMLElement.swift
//  Extensions
//
//  Created by Matias Piipari on 24/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

enum ElementError:ErrorType {
    case UnexpectedTagName(String)
    case UnexpectedSnippet(String)
}

public class SimpleInlineElement: NSObject, InlineElement {
    public let contents: String
    public let tagName: String
    public let attributes: [String:String]
    
    public init(contents:String, tagName:String = "span", attributes:[String:String] = [:]) {
        self.contents = contents
        self.tagName = tagName
        self.attributes = attributes
    }
    
    public class var tagName: String {
        return "span"
    }
    
    public override var description: String {
        return "<\(String(self.dynamicType)) tagName:\(tagName) contents:\(contents)>"
    }
}

public class SimpleBlockElement: NSObject, BlockElement {
    public let contents: String
    public let tagName: String
    public let attributes: [String : String]
    
    public init(contents:String, tagName:String = "div", attributes: [String : String] = [:]) {
        self.contents = contents
        self.tagName = tagName
        self.attributes = attributes
    }
    
    public override var description: String {
        return "<\(String(self.dynamicType)) tagName:\(tagName) contents:\(contents)>"
    }
}

func element(tagName tagName:String, contents:String, attributes:[String:String] = [:]) throws -> Element {
    let lowercaseTagName = tagName.lowercaseString

    switch lowercaseTagName {
    case "p", "div":
        return SimpleBlockElement(contents: contents, tagName: tagName, attributes: attributes)
        
    case "span", "strong", "em", "i", "b":
        return SimpleInlineElement(contents: contents, tagName: tagName, attributes: attributes)
        
    default:
        throw ElementError.UnexpectedTagName(tagName)
    }
}

func element(HTMLSnippet snippet:String) throws -> Element {
    let doc = try NSXMLDocument(XMLString: snippet, options: Int(MPDefaultXMLDocumentParsingOptions))
    
    if let root = doc.rootElement(), let rootTagName = root.name, let children = root.children {
        
        var attribs = [String:String]()
        for key in root.attributeKeys {
            if let value = root.attributeForName(key)?.stringValue {
                attribs[key] = value
            }
        }
        
        let str = children.map {
            return $0.XMLStringWithOptions(Int(MPDefaultXMLDocumentOutputOptions))
        }.joinWithSeparator("")
        
        return try element(tagName:rootTagName, contents:str, attributes: attribs)
    }
    
    throw ElementError.UnexpectedSnippet(snippet)
}
