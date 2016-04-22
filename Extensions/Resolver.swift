//
//  ResolverService.swift
//  Extensions
//
//  Created by Matias Piipari on 20/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

public enum ResolvableResult {
    case None
    case BibliographyItems([AnyObject])
}

public protocol Resolver {
    func baseURL() -> NSURL
    func resolve(resolvable:Resolvable) -> ResolvableResult
}