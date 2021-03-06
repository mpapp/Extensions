//
//  HTMLSnippetRepresentable.swift
//  Extensions
//
//  Created by Matias Piipari on 24/04/2016.
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
        let trimmedAttribsString = attribsString.trimmingCharacters(in: CharacterSet(charactersIn: " "))
        let str = "<\(self.tagName ) \(trimmedAttribsString)>\(self.innerHTML)</\(self.tagName)>"
        return str
    }
}
