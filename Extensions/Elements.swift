//
//  ElementTypes.swift
//  Extensions
//
//  Created by Matias Piipari on 22/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

public protocol Element: class, HTMLSnippetRepresentable, CustomStringConvertible {
    var contents:String { get }
    var tagName: String { get }
}

public extension Element {
    var description:String {
        return "<\(String(self.dynamicType)) tagName:\(tagName) contents:\(contents)>"
    }
}

public protocol InlineElement: class, Element {
}

public protocol BlockElement: class, Element {
}

// implements HTMLSnippetRepresentable
extension Element {
    public var innerHTML:String {
        return self.contents
    }
    
    public var attributeDictionary:[String:String] {
        return [:]
    }
}
