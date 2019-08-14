//
//  ElementTypes.swift
//  Extensions
//
//  Created by Matias Piipari on 22/04/2016.
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

public protocol InlineElement: Element {
}

public protocol BlockElement: Element {
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
