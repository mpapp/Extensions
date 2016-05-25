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
    case UnexpectedResponseData(NSData)
    case UnexpectedResponseObject(Any)
    case MissingIdentifier(Any)
    case UnexpectedResolvedResponse(ResolvedResult)
    case MissingQuery(NSURLComponents)
}

public protocol Resolvable: CustomStringConvertible {
    var identifier:String { get }
    var originatingString:String { get }
    
    init(originatingString:String) throws
    
    static func capturingPattern() -> String
}

extension Resolvable {
    public var description:String {
        return "<\(self.dynamicType) \(self.identifier)>"
    }
}