//
//  SimpleBibliographicDate.swift
//  Extensions
//
//  Created by Matias Piipari on 23/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation
import Freddy

public class SimpleBibliographicDate: NSObject, BibliographicDate, JSONDecodable, JSONEncodable {
    
    public var circa:Bool = false
    public var dateParts:[AnyObject]? = nil
    public var beginDateParts:[AnyObject]? = nil
    public var endDateParts:[AnyObject]? = nil
    public var raw:String? = nil
    public var season:BibliographicDateSeason = .Unknown
    public var seasonLiteral:String? = nil
    public var literal:String? = nil
    
    public required init(json: JSON) throws {
        if let circa = try json.bool("circa", alongPath: [.MissingKeyBecomesNil]) {
            self.circa = circa
        }
        
        do { self.dateParts = try json.arrayOf("date-parts", type:String.self) }
        catch {
            do { self.dateParts = try json.arrayOf("date-parts", type:Int.self) }
            catch {
                do { self.beginDateParts = try json.array("date-parts")[0].arrayOf(type:String.self) }
                catch { do { self.beginDateParts = try json.array("date-parts")[0].arrayOf(type:Int.self) } catch {} }
                
                if try json.array("date-parts").count == 2 {
                    do { self.endDateParts = try json.array("date-parts")[1].arrayOf(type:String.self) }
                    catch { do { self.endDateParts = try json.array("date-parts")[1].arrayOf(type:Int.self) } catch {} }
                }
            }
        }
        
        self.raw = try json.string("raw", alongPath: [.MissingKeyBecomesNil])
        
        do {
            if let seasonStr = try json.string("season", alongPath: [.MissingKeyBecomesNil]) {
                self.seasonLiteral = seasonStr
            }
        }
        catch {
            do {
                if let seasonStr = try json.string("season", alongPath: [.MissingKeyBecomesNil]),
                       seasonNum = UInt(seasonStr),
                       season = BibliographicDateSeason(rawValue:seasonNum) {
                    self.season = season
                }
            }
            catch { }
        }
        
        self.seasonLiteral = try json.string("season", alongPath: [.MissingKeyBecomesNil])
    }
    
    public class func isValidDatePartsArray(dateParts:[AnyObject]) throws -> Void {
        // special case for ranges (call recursively on both range components):
        //        "date-parts" : [
        //                        [ 2000, 11 ],
        //                        [ 2000, 12 ]
        //                       ]
        //
        
        if let firstPartArray = dateParts.first as? [AnyObject] where dateParts.count == 2,
           let secondPartArray = dateParts[1] as? [AnyObject] {
            try self.isValidDatePartsArray(firstPartArray)
            try self.isValidDatePartsArray(secondPartArray)
            
            return
        }
        
        if dateParts.count > 3 {
            throw BibliographicDateValidationError.InvalidComponentCount
        }
        
        for dp in dateParts {
            if !(dp is NSNumber) {
                throw BibliographicDateValidationError.InvalidComponentType
            }
        }
    }
    
    public class func openEndedDateParts() -> [NSNumber] {
        return [false, false]
    }

    public var dictionaryRepresentation:[String : AnyObject] {
        var dict = [String:AnyObject]()
        
        if let literal = self.literal {
            dict["literal"] = literal
        }
        else if self.dateParts != nil {
            dict["date-parts"] = self.dateParts
        }
        else if self.beginDateParts != nil || self.endDateParts != nil {
            dict["date-parts"] = [self.beginDateParts ?? self.dynamicType.openEndedDateParts(),
                                  self.endDateParts ?? self.dynamicType.openEndedDateParts()]
        }
        
        if self.circa {
            dict["circa"] = true
        }
        
        if self.season != .Unknown {
            dict["season"] = "\(self.season)"
        }
        
        return dict
    }
    
    public func toJSON() -> JSON {
        let data = try! NSJSONSerialization.dataWithJSONObject(self.dictionaryRepresentation, options: [])
        return try! JSON(data:data)
    }
}