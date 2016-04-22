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
    case InvalidResolverURL(NSURL)
    case InvalidResolverURLComponents(NSURLComponents)
    case UnexpectedResponse(NSURLResponse?)
    case UnexpectedStatusCode(Int)
}

public protocol Resolvable {
    var identifier:String { get }
    init(identifier:String) throws
}