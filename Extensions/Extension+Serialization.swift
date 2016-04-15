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
        self.identifier = try json.string("CFBundleIdentifier")
        
        let procedures = try json.array("ExtensionProcedures").map { (procedureJSON:JSON) -> Procedure in
            return try Procedure(json: procedureJSON)
        }
        
        self.procedures = procedures
    }
}

extension Procedure: JSONEncodable {
    func toJSON() -> JSON {
        return .Dictionary(["source":.String(self.source),
                            "evaluator":.String(self.evaluatorID)])
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
    
    public class func fromPropertyListRepresentation(propertyList plist: [String:AnyObject], rootURL:NSURL) throws -> Extension {
        let data = try NSJSONSerialization.dataWithJSONObject(plist, options: [])
        guard let str = String(data: data, encoding: NSUTF8StringEncoding) else {
            throw ExtensionError.NotPropertyList(plist)
        }
        
        let json = try JSON(jsonString: str)
        let extensionDesc = try ExtensionDescription(json: json)
        
        return Extension(identifier: extensionDesc.identifier, rootURL:rootURL, procedures: extensionDesc.procedures)
    }
    
    public class func fromBundle(bundle:NSBundle) throws -> Extension {
        guard let infoDictionary = bundle.infoDictionary else {
            throw ExtensionError.MissingInfoDictionary(bundle)
        }
        
        return try Extension.fromPropertyListRepresentation(propertyList: infoDictionary.JSONEncodable, rootURL:bundle.bundleURL)
    }
}