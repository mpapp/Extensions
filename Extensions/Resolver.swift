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
    
    func resolve(_ string:String) throws -> ResolvedResult
    
    var rateLimitLabel:String { get }
    var rateLimit:TimeInterval { get }
    
    var replaceMatches:Bool { get }
    
    static var identifier:String { get }
}

public protocol URLBasedResolver:Resolver {
    func baseURL() -> URL
}

public extension Resolver {
    
    var rateLimitLabel: String {
        return String(describing: type(of: self))
    }
    
    var rateLimit: TimeInterval {
        return 1.0
    }
    
    var replaceMatches: Bool {
        return true // override in your resolver to limit whether the resolver ever results in replacing.
    }
}

/*
extension URLBasedResolver {
    
    public var replaceMatches:Bool {
        return false
    }
}
*/
