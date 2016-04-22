//
//  Resolvable.swift
//  Extensions
//
//  Created by Matias Piipari on 20/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

enum ResolvingError:ErrorType {
    case NotResolvable(String)
}

public protocol Resolvable {
    var identifier:String { get }
    init(identifier:String) throws
}