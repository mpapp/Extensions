//
//  Resolvable.swift
//  Extensions
//
//  Created by Matias Piipari on 20/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

enum ResolvingError:Error {
    case notResolvable(String)
    case invalidResolverURL(URL)
    case invalidResolverURLComponents(URLComponents)
    case unexpectedResponse(URLResponse?)
    case unexpectedStatusCode(Int)
    case unexpectedResponseData(Data)
    case unexpectedResponseObject(Any)
    case missingIdentifier(Any)
    case unexpectedResolvedResponse(ResolvedResult)
    case missingQuery(URLComponents)
}

public protocol Resolvable: CustomStringConvertible {
    var identifier:String { get }
    var originatingString:String { get }
    
    init(originatingString:String) throws
    
    static func capturingPattern() -> String
}

extension Resolvable {
    public var description:String {
        return "<\(type(of: self)) \(self.identifier)>"
    }
}
