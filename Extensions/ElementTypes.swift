//
//  ElementTypes.swift
//  Extensions
//
//  Created by Matias Piipari on 22/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

@objc public protocol InlineElement: class {
}

@objc public protocol BlockElement: class {
    var contents:String { get }
}