//
//  SimpleInlineMathFragment.swift
//  Extensions
//
//  Created by Matias Piipari on 24/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation
import Freddy

open class SimpleInlineMathFragment: NSObject, InlineMathFragment, JSONDecodable, JSONEncodable {
    open let TeXRepresentation:String
    
    public init(TeXRepresentation:String) {
        self.TeXRepresentation = TeXRepresentation
    }
    
    open var contents: String {
        return self.TeXRepresentation
    }
    
    public required init(json:JSON) throws {
        guard let TeXRepresentation = try json.getString(at: "TeXRepresentation",
                                                         alongPath:[.missingKeyBecomesNil]) else {
            throw SimpleEquationError.missingContents(json)
        }
        
        self.TeXRepresentation = TeXRepresentation
    }
    
    open func toJSON() -> JSON {
        return [
            "TeXRepresentation":.string(self.TeXRepresentation)
        ]
    }
    
    open var tagName: String {
        return "span"
    }
}
