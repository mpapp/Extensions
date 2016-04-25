//
//  SimpleEquation.swift
//  Extensions
//
//  Created by Matias Piipari on 24/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation
import Freddy

enum SimpleEquationError:ErrorType {
    case MissingContents(JSON)
}

public class SimpleEquation: NSObject, Equation, JSONDecodable, JSONEncodable {
    
    public var TeXRepresentation:String {
        return self.contents
    }
    
    public let contents:String
    
    public init(TeXRepresentation:String) {
        self.contents = TeXRepresentation
    }
    
    public required init(json:JSON) throws {
        guard let contents = try json.string("contents", alongPath:[.MissingKeyBecomesNil]) else {
            throw SimpleEquationError.MissingContents(json)
        }
        
        self.contents = contents
    }
    
    public var tagName: String {
        return "div"
    }
    
    public func toJSON() -> JSON {
        return [
            "TeXRepresentation":.String(self.TeXRepresentation)
        ]
    }
}