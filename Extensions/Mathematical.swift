//
//  Mathematical.swift
//  Extensions
//
//  Created by Matias Piipari on 22/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

public protocol Mathematical: CustomStringConvertible {
    var TeXRepresentation:String { get }
}

public extension Mathematical {
    var description: String {
        return "<\(String(self.dynamicType)) TeXRepresentation:\(self.TeXRepresentation)>"
    }
}

public protocol InlineMathFragment:Mathematical, InlineElement {
}

public protocol Equation:Mathematical, BlockElement {
}