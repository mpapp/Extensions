//
//  Extension+JSONSerialization.swift
//  Extensions
//
//  Created by Matias Piipari on 08/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation
import Freddy
import ObjectiveC

// An ExtensionDescription is is a utility struct for (de)serialising Extension objects (allows for mutable identifier / evaluator).
class ExtensionDescription: JSONDecodable, ExtensionLike {
    
    var identifier:String
    var procedures: [Procedure]
    
    required init(json: JSON) throws {
        self.identifier = try json.string("identifier")
        
        self.procedures = try json.array("procedures").map { (procedureJSON:JSON) -> Procedure in
            return try Procedure(json: procedureJSON)
        }
    }
}

extension Procedure: JSONEncodable {
    func toJSON() -> JSON {
        return .Dictionary(["source":.String(self.source),
                            "evaluator":.String(NSStringFromClass(self.evaluator.dynamicType)),
                            "resources":.Array(self.resources.map { return JSON($0.absoluteString) } )])
    }
}

extension Extension: JSONEncodable {
    public func toJSON() -> JSON {
        
        let proceduresJSON = self.procedures.map { return $0.toJSON() }
        
        return .Dictionary(["identifier":.String(self.identifier),
                            "procedures":.Array(proceduresJSON)])
    }
}

extension Extension {
    
    public func propertyListRepresentation() throws -> [String:AnyObject] {
        let data = try self.toJSON().serialize()
        let json = try NSJSONSerialization.JSONObjectWithData(data, options: [])
        guard let jsonDict = json as? [String : AnyObject] else {
            preconditionFailure("Unexpectedly failed to represent \(self) in property list form.")
        }
        
        return jsonDict
    }
    
    public class func fromPropertyListRepresentation(propertyList plist: [String:AnyObject]) throws -> Extension {
        let data = try NSJSONSerialization.dataWithJSONObject(plist, options: [])
        guard let str = String(data: data, encoding: NSUTF8StringEncoding) else {
            throw ExtensionError.NotPropertyList(plist)
        }
        
        let json = try JSON(jsonString: str)
        let extensionDesc = try ExtensionDescription(json: json)
        
        return Extension(identifier: extensionDesc.identifier, procedures: extensionDesc.procedures)
    }
    
}