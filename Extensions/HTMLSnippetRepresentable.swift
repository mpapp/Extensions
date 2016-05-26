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
        
        let attribsString = attributes.reduce("") { (initial:String, kp: (key:String, value:String)) -> String in
            return initial + "\(kp.key)=\"\(kp.value)\" "
        }
        let trimmedAttribsString = attribsString.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: " "))
        let str = "<\(self.tagName ) \(trimmedAttribsString)>\(self.innerHTML)</\(self.tagName)>"
        return str
    }
}