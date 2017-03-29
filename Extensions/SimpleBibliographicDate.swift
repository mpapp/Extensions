//
//  SimpleBibliographicDate.swift
//  Extensions
//
//  Created by Matias Piipari on 23/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation
import Freddy

open class SimpleBibliographicDate: NSObject, BibliographicDate, JSONDecodable, JSONEncodable {
            
    open var circa:Bool = false
    open var dateParts:[Any]? = nil
    open var beginDateParts:[Any]? = nil
    open var endDateParts:[Any]? = nil
    open var raw:String? = nil
    open var season:BibliographicDateSeason = .unknown
    open var seasonLiteral:String? = nil
    open var literal:String? = nil
    
    public init(dateParts:[Any]) {
        self.dateParts = dateParts
    }
    
    public enum Error: Swift.Error {
        case unexpectedDatePartsArray([JSON])
    }
    
    public required init(json: JSON) throws {
        if let circa = try json.getBool(at: "circa", alongPath: [.missingKeyBecomesNil]) {
            self.circa = circa
        }
        
        do {
            if let datePartsArray = try json.getArray(at: "date-parts", alongPath: [.missingKeyBecomesNil]), let firstItem = datePartsArray.first {
                // let's see if it's an array of ints
                do {
                    _ = try firstItem.getInt()
                    
                    self.dateParts = (try datePartsArray.map { try $0.getInt() }) as [NSNumber]
                }
                catch {
                    // was not an array of ints – let's now see if first item is an array of arrays of ints
                    
                    let firstArray = try firstItem.getArray() // if it weren't an array of arrays of ints, it actually really is unexpected input, hence no catch here.
                    let lastItem:JSON? = datePartsArray.last
                    
                    if datePartsArray.count == 1 {
                        self.dateParts = [try firstArray.map { NSNumber(value: try $0.getInt()) }]
                    }
                    else if let lastArray = try lastItem?.getArray(), datePartsArray.count == 2 {
                        self.beginDateParts = [try firstArray.map { try $0.getInt() }]
                        self.endDateParts = [try lastArray.map { try $0.getInt() }]
                    }
                    else {
                        throw Error.unexpectedDatePartsArray(datePartsArray)
                    }
                }
            }
        }
        
        self.raw = try json.getString(at: "raw", alongPath: [.missingKeyBecomesNil])
        
        do {
            if let seasonStr = try json.getString(at: "season", alongPath: [.missingKeyBecomesNil]) {
                self.seasonLiteral = seasonStr
            }
        }
        catch {
            do {
                if let seasonStr = try json.getString(at: "season", alongPath: [.missingKeyBecomesNil]),
                       let seasonNum = UInt(seasonStr),
                       let season = BibliographicDateSeason(rawValue:seasonNum) {
                    self.season = season
                }
            }
            catch { }
        }
        
        self.seasonLiteral = try json.getString(at: "season", alongPath: [.missingKeyBecomesNil])
    }
    
    open class func isValidDatePartsArray(_ dateParts:[AnyObject]) throws -> Void {
        // special case for ranges (call recursively on both range components):
        //        "date-parts" : [
        //                        [ 2000, 11 ],
        //                        [ 2000, 12 ]
        //                       ]
        //
        
        if let firstPartArray = dateParts.first as? [AnyObject], dateParts.count == 2,
           let secondPartArray = dateParts[1] as? [AnyObject] {
            try self.isValidDatePartsArray(firstPartArray)
            try self.isValidDatePartsArray(secondPartArray)
            
            return
        }
        
        if dateParts.count > 3 {
            throw BibliographicDateValidationError.invalidComponentCount
        }
        
        for dp in dateParts {
            if !(dp is NSNumber) {
                throw BibliographicDateValidationError.invalidComponentType
            }
        }
    }
    
    open class func openEndedDateParts() -> [NSNumber] {
        return [false, false]
    }

    open var dictionaryRepresentation:[String : Any] {
        var dict = [String:Any]()
        
        if let literal = self.literal {
            dict["literal"] = literal
        }
        else if self.dateParts != nil {
            dict["date-parts"] = self.dateParts
        }
        else if self.beginDateParts != nil || self.endDateParts != nil {
            dict["date-parts"] = [ self.beginDateParts ?? type(of: self).openEndedDateParts(),
                                   self.endDateParts ?? type(of: self).openEndedDateParts() ]
        }
        
        if self.circa {
            dict["circa"] = true
        }
        
        if self.season != .unknown {
            dict["season"] = "\(self.season)"
        }
        
        return dict
    }
    
    open func toJSON() -> JSON {
        let data = try! JSONSerialization.data(withJSONObject: self.dictionaryRepresentation, options: [])
        return try! JSON(data:data)
    }
}
