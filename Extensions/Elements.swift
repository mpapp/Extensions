//
//  ElementTypes.swift
//  Extensions
//
//  Created by Matias Piipari on 22/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

public protocol Element: class, HTMLSnippetRepresentable {
    var contents:String { get }
    var tagName: String { get }
    var attributes:[String:String] { get }
}

public extension Element {
    var description:String {
        return "<\(String(describing: type(of: self))) tagName:\(tagName) contents:\(contents) attributes:\(attributes)>"
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
    
    public var attributes:[String:String] {
        return [:]
    }
}
