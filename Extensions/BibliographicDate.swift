//
//  BibliographicDate.swift
//  Extensions
//
//  Created by Matias Piipari on 23/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

@objc public enum BibliographicDatePart:UInt {
    case Year = 0
    case Month = 1
    case Day = 2
}

@objc public enum BibliographicDateSeason:UInt {
    case Unknown = 0
    case Spring = 1
    case Summer = 2
    case Autumn = 3
    case Winter = 4
}

@objc public protocol BibliographicDate: DictionaryRepresentable {

    var circa:Bool { get }
    
    var beginDateParts:[AnyObject] { get }

    var endDateParts:[AnyObject] { get }

    var raw:String { get }

    var season:BibliographicDateSeason { get }

    var seasonLiteral:String { get }
    
}