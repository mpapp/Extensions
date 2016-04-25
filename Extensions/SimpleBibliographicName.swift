//
//  SimpleBibliographicName.swift
//  Extensions
//
//  Created by Matias Piipari on 23/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation
import Freddy

public class SimpleBibliographicName: NSObject, BibliographicName, JSONDecodable, JSONEncodable {
    
    public var family: String?
    public var given: String?
    public var suffix: String?
    public var droppingParticle: String?
    public var nonDroppingParticle: String?
    public var literal: String?
    
    public required init(json: JSON) throws {
        self.family = try json.string("family", alongPath: [.MissingKeyBecomesNil])
        self.given = try json.string("given", alongPath: [.MissingKeyBecomesNil])
        self.suffix = try json.string("suffix", alongPath: [.MissingKeyBecomesNil])
        self.droppingParticle = try json.string("dropping-particle", alongPath: [.MissingKeyBecomesNil])
        self.nonDroppingParticle = try json.string("non-dropping-particle", alongPath: [.MissingKeyBecomesNil])
        self.literal = try json.string("literal", alongPath: [.MissingKeyBecomesNil])
    }
    
    public var dictionaryRepresentation:[String : AnyObject] {
        var dict = [String:AnyObject]()
        
        if let family = self.family { dict["family"] = family }
        if let given = self.given { dict["given"] = given }
        if let suffix = self.suffix { dict["suffix"] = suffix }
        if let droppingParticle = self.droppingParticle { dict["dropping-particle"] = droppingParticle }
        if let nonDroppingParticle = self.nonDroppingParticle { dict["non-dropping-particle"] = nonDroppingParticle }
        if let literal = self.literal { dict["literal"] = literal }
        
        return dict
    }
    
    public func toJSON() -> JSON {
        let data = try! NSJSONSerialization.dataWithJSONObject(self.dictionaryRepresentation, options: [])
        return try! JSON(data:data)
    }
}