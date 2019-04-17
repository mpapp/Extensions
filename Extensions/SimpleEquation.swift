//
//  SimpleEquation.swift
//  Extensions
//
//  Created by Matias Piipari on 24/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation
import Freddy

enum SimpleEquationError:Error {
    case missingContents(JSON)
}

open class SimpleEquation: NSObject, Equation, JSONDecodable, JSONEncodable {
    
    open var TeXRepresentation:String {
        return self.contents
    }
    
    public let contents: String
    
    public init(TeXRepresentation:String) {
        self.contents = TeXRepresentation
    }
    
    public required init(json:JSON) throws {
        guard let contents = try json.getString(at: "contents", alongPath: [.missingKeyBecomesNil]) else {
            throw SimpleEquationError.missingContents(json)
        }
        
        self.contents = contents
    }
    
    open var tagName: String {
        return "div"
    }
    
    open func toJSON() -> JSON {
        return [
            "TeXRepresentation": .string(self.TeXRepresentation)
        ]
    }
}
