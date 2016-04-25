//
//  InlineHTMLElement.swift
//  Extensions
//
//  Created by Matias Piipari on 24/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

public class SimpleInlineElement: NSObject, InlineElement {
    public let contents: String
    
    public init(contents:String, tagName:String) {
        self.contents = contents
    }
    
    public class var tagName: String {
        return "span"
    }
}

public class SimpleBlockElement: NSObject, BlockElement {
    public let contents: String
    public let tagName: String
    
    public init(contents:String, tagName:String) {
        self.contents = contents
        self.tagName = tagName
    }
    
    public class var tagName: String {
        return "div"
    }
}