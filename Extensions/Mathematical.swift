//
//  Mathematical.swift
//  Extensions
//
//  Created by Matias Piipari on 22/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

public protocol Mathematical {
    var TeXRepresentation:String { get }
}

public protocol InlineMathFragment:Mathematical, InlineElement {
}

public protocol Equation:Mathematical, BlockElement {
}