//
//  BibliographicDate.swift
//  Extensions
//
//  Created by Matias Piipari on 23/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

public enum BibliographicDateValidationError:UInt, Error {
    case invalidComponentCount = 1
    case invalidComponentType = 2
    case missingRequiredComponent = 3
};

public enum BibliographicDatePart:UInt {
    case year = 0
    case month = 1
    case day = 2
}

public enum BibliographicDateSeason:UInt {
    case unknown = 0
    case spring = 1
    case summer = 2
    case autumn = 3
    case winter = 4
}

public protocol BibliographicDate: DictionaryRepresentable {

    var circa:Bool { get }
    
    var dateParts:[Any]? { get }
    
    var beginDateParts:[Any]? { get }

    var endDateParts:[Any]? { get }

    var raw:String? { get }

    var season:BibliographicDateSeason { get }

    var seasonLiteral:String? { get }
    
    var literal:String? { get }
}
