//
//  SimpleInlineMathFragment.swift
//  Extensions
//
//  Created by Matias Piipari on 24/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation
import Freddy

public class SimpleInlineMathFragment: NSObject, InlineMathFragment, JSONDecodable, JSONEncodable {
    public let TeXRepresentation:String
    
    public init(TeXRepresentation:String) {
        self.TeXRepresentation = TeXRepresentation
    }
    
    public var contents: String {
        return self.TeXRepresentation
    }
    
    public required init(json:JSON) throws {
        guard let TeXRepresentation = try json.string("TeXRepresentation", alongPath:[.MissingKeyBecomesNil]) else {
            throw SimpleEquationError.MissingContents(json)
        }
        
        self.TeXRepresentation = TeXRepresentation
    }
    
    public func toJSON() -> JSON {
        return [
            "TeXRepresentation":.String(self.TeXRepresentation)
        ]
    }
    
    public var tagName: String {
        return "span"
    }
}