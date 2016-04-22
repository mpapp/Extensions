//
//  Mathematical.swift
//  Extensions
//
//  Created by Matias Piipari on 22/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

@objc public protocol Mathematical {
    var TeXRepresentation:String { get }
}

@objc public protocol InlineMathFragment:Mathematical, InlineElement {
}

@objc public protocol Equation:Mathematical, BlockElement {
}