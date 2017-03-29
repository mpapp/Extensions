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
        self.identifier = try json.getString(at: "CFBundleIdentifier")
        
        let procedures = try json.getArray(at: "ExtensionProcedures").map { (procedureJSON:JSON) -> Procedure in
            return try Procedure(json: procedureJSON)
        }
        
        self.procedures = procedures
    }
}

extension Procedure: JSONEncodable {
    public func toJSON() -> JSON {
        return .dictionary(["source":.string(self.source),
                            "evaluator":.string(self.evaluatorID)])
    }
}

extension Extension: JSONEncodable {
    public func toJSON() -> JSON {
        
        let proceduresJSON = self.procedures.map { return $0.toJSON() }
        
        return .dictionary(["identifier":.string(self.identifier),
                            "procedures":.array(proceduresJSON)])
    }
}

extension Extension {
    
    public func propertyListRepresentation() throws -> [String:AnyObject] {
        let data = try self.toJSON().serialize()
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        guard let jsonDict = json as? [String : AnyObject] else {
            preconditionFailure("Unexpectedly failed to represent \(self) in property list form.")
        }
        
        return jsonDict
    }
    
    public class func fromPropertyListRepresentation(propertyList plist: [String:Any], rootURL:URL) throws -> Extension {
        // We know to be dealing with the subset of plist encodable data that is also JSON encodable (a stricter requirement).
        // Therefore we funnel also the plist based initialization route via the JSON based initialization.
        let data = try JSONSerialization.data(withJSONObject: plist, options: [])
        guard let str = String(data: data, encoding: String.Encoding.utf8) else {
            throw ExtensionError.notPropertyList(plist)
        }
        
        let json = try JSON(jsonString: str)
        let extensionDesc = try ExtensionDescription(json: json)
        
        return Extension(identifier: extensionDesc.identifier, rootURL:rootURL, procedures: extensionDesc.procedures)
    }
    
    public class func fromBundle(_ bundle:Bundle) throws -> Extension {
        guard let infoDictionary = bundle.infoDictionary else {
            throw ExtensionError.missingInfoDictionary(bundle)
        }

        return try Extension.fromPropertyListRepresentation(propertyList: infoDictionary.JSONEncodable, rootURL:bundle.bundleURL)
    }
}
