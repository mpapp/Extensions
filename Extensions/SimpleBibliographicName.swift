//
//  SimpleBibliographicName.swift
//  Extensions
//
//  Created by Matias Piipari on 23/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation
import Freddy

@objc open class SimpleBibliographicName: NSObject, BibliographicName, JSONDecodable, JSONEncodable {
    
    open var family: String?
    open var given: String?
    open var suffix: String?
    open var droppingParticle: String?
    open var nonDroppingParticle: String?
    open var literal: String?
    
    public override convenience init() {
        self.init(family:nil, given:nil, suffix:nil, droppingParticle: nil, nonDroppingParticle: nil, literal:nil)
    }
    
    public init(family:String?, given:String?, suffix:String?, droppingParticle:String?, nonDroppingParticle:String?, literal:String?) {
        super.init()
        self.family = family
        self.given = given
        self.suffix = suffix
        self.droppingParticle = droppingParticle
        self.nonDroppingParticle = nonDroppingParticle
        self.literal = literal
    }
    
    public required init(json: JSON) throws {
        self.family = try json.getString(at: "family", alongPath: [.missingKeyBecomesNil])
        self.given = try json.getString(at: "given", alongPath: [.missingKeyBecomesNil])
        self.suffix = try json.getString(at: "suffix", alongPath: [.missingKeyBecomesNil])
        self.droppingParticle = try json.getString(at: "dropping-particle", alongPath: [.missingKeyBecomesNil])
        self.nonDroppingParticle = try json.getString(at: "non-dropping-particle", alongPath: [.missingKeyBecomesNil])
        self.literal = try json.getString(at: "literal", alongPath: [.missingKeyBecomesNil])
    }
    
    open var dictionaryRepresentation:[String : Any] {
        var dict = [String:Any]()
        
        if let family = self.family { dict["family"] = family }
        if let given = self.given { dict["given"] = given }
        if let suffix = self.suffix { dict["suffix"] = suffix }
        if let droppingParticle = self.droppingParticle { dict["dropping-particle"] = droppingParticle }
        if let nonDroppingParticle = self.nonDroppingParticle { dict["non-dropping-particle"] = nonDroppingParticle }
        if let literal = self.literal { dict["literal"] = literal }
        
        return dict
    }
    
    open func toJSON() -> JSON {
        let data = try! JSONSerialization.data(withJSONObject: self.dictionaryRepresentation, options: [])
        return try! JSON(data:data)
    }
}
