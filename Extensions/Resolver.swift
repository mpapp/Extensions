//
//  ResolverService.swift
//  Extensions
//
//  Created by Matias Piipari on 20/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

public let ResolverRateLimitMilliseconds = 100

public protocol Resolver {
    var resolvableType:Resolvable.Type { get }
    
    func resolve(identifier:String) throws -> ResolvedResult
    
    var rateLimitLabel:String { get }
    var rateLimit:NSTimeInterval { get }
}

public protocol URLBasedResolver:Resolver {
    func baseURL() -> NSURL
}

public extension Resolver {
    
    public var rateLimitLabel:String {
        return String(self.dynamicType)
    }
    
    public var rateLimit:NSTimeInterval {
        return 1.0
    }
    
}