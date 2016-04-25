//
//  ElementTypes.swift
//  Extensions
//
//  Created by Matias Piipari on 22/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

@objc public protocol Element: class {
    var contents:String { get }
    static var tagName: String { get }
}

@objc public protocol InlineElement: class, Element {
}

@objc public protocol BlockElement: class, Element {
}