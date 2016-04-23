//
//  SimpleBibliographyItem.swift
//  Extensions
//
//  Created by Matias Piipari on 20/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

@objc public class SimpleBibliographyItem: NSObject, BibliographyItem {

    public var abstract:String? = nil
    
    public var annote:String? = nil
    
    public var archive:String? = nil
    
    public var archiveLocation:String? = nil
    
    public var archivePlace:String? = nil
    
    public var authority:String? = nil
    
    public var callNumber:String? = nil
    
    public var chapterNumber:Int = 0
    
    public var citationLabel:String? = nil
    
    public var collectionEditor:String? = nil
    
    public var collectionNumber:String? = nil
    
    public var collectionTitle:String? = nil
    
    public var composer:String? = nil
    
    public var containerAuthor:String? = nil
    
    public var containerTitle:String? = nil
    
    public var containerTitleShort:String? = nil
    
    public var dimensions:String? = nil
    
    public var director:String? = nil
    
    public var DOI:String? = nil
    
    public var edition:Int = 0
    
    public var editor:String? = nil
    
    public var editorialDirector:String? = nil
    
    public var event:String? = nil
    
    public var eventPlace:String? = nil
    
    public var genre:String? = nil
    
    public var illustrator:String? = nil
    
    public var interviewer:String? = nil
    
    public var ISBN:String? = nil
    
    public var ISSN:String? = nil
    
    public var issue:Int = 0
    
    public var jurisdiction:String? = nil
    
    public var keyword:String? = nil
    
    public var language:String? = nil
    
    public var locator:String? = nil
    
    public var medium:String? = nil
    
    public var note:String? = nil
    
    public var number:Int = 0
    
    public var numberOfPages:Int = 0
    
    public var numberOfVolumes:Int = 0
    
    public var originalPublisher:String? = nil
    
    public var originalPublisherPlace:String? = nil
    
    public var originalTitle:String? = nil
    
    public var page:String? = nil
    
    public var pageFirst:String? = nil
    
    public var PMCID:String? = nil
    
    public var PMID:String? = nil
    
    public var publisher:String? = nil
    
    public var publisherPlace:String? = nil
    
    public var recipient:String? = nil
    
    public var references:String? = nil
    
    public var reviewedAuthor:String? = nil
    
    public var reviewedTitle:String? = nil
     
    public var scale:String? = nil
    
    public var section:String? = nil
    
    public var source:String? = nil
    
    public var status:String? = nil
    
    public var title:String? = nil
    
    public var titleShort:String? = nil
    
    public var translator:String? = nil
    
    public var URL:NSURL? = nil
    
    public var version:String? = nil
    
    public var volume:String? = nil
    
    public var yearSuffix:String? = nil
    
    public var institution:String? = nil
    
    public func dictionaryRepresentation() -> [String : AnyObject] {
        return [:]
    }
}