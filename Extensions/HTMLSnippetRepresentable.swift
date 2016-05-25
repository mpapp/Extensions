//
//  HTMLSnippetRepresentable.swift
//  Extensions
//
//  Created by Matias Piipari on 24/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

public protocol HTMLSnippetRepresentable:CustomStringConvertible {
    var tagName:String { get }
    var innerHTML:String { get }
    var attributes:[String:String] { get }
    
    var HTMLSnippetRepresentation: String { get }
}

extension HTMLSnippetRepresentable {
    public var HTMLSnippetRepresentation: String {
        let str = "<\(self.tagName )>\(self.innerHTML)</\(self.tagName)>"
        return str
    }
}