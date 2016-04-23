//
//  SimpleBibliographyItem.swift
//  Extensions
//
//  Created by Matias Piipari on 20/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation
import Freddy

@objc public class SimpleBibliographyItem: NSObject, BibliographyItem, JSONEncodable {

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
    
    //public func toJSON() -> JSON {
    //
    //}
    
    public func dictionaryRepresentation() -> [String : AnyObject] {
        var dict = [String:AnyObject]()
        
        if let abstract = self.abstract { dict["abstract"] = abstract }
        if let annote = self.abstract { dict["annote"] = annote }
        if let archive = self.archive { dict["archive"] = archive }
        if let archiveLocation = self.archiveLocation { dict["archive-location"] = archiveLocation }
        if let archivePlace = self.archivePlace { dict["archive-place"] = archivePlace }
        if let authority = self.authority { dict["authority"] = authority }
        if let callNumber = self.callNumber { dict["call-number"] = callNumber }
        dict["chapter-number"] = self.chapterNumber
        if let citationLabel = self.citationLabel { dict["citation-label"] = citationLabel }
        if let collectionEditor = self.collectionEditor { dict["collection-editor"] = collectionEditor }
        if let collectionNumber = self.collectionNumber { dict["collection-number"] = collectionNumber }
        if let collectionTitle = self.collectionTitle { dict["collection-title"] = collectionTitle }
        if let composer = self.composer { dict["composer"] = composer }
        
        if let containerAuthor = self.containerAuthor { dict["container-author"] = containerAuthor }
        if let containerTitle = self.containerTitle { dict["container-title"] = containerTitle }
        if let containerTitleShort = self.containerTitleShort { dict["container-title-short"] = containerTitleShort }
        if let dimensions = dimensions { dict["dimensions"] = dimensions }
        if let director = director { dict["director"] = director }
        if let DOI = DOI { dict["DOI"] = DOI }
        dict["edition"] = edition
        if let editor = editor { dict["editor"] = editor }
        if let editorialDirector = editorialDirector { dict["editorial-director"] = editorialDirector }
        if let event = event { dict["event"] = event }
        if let eventPlace = eventPlace { dict["event-place"] = eventPlace }
        if let genre = genre { dict["genre"] = genre }
        if let illustrator = illustrator { dict["illustrator"] = illustrator }
        if let interviewer = interviewer { dict["interviewer"] = interviewer }
        if let ISBN = ISBN { dict["ISBN"] = ISBN }
        if let ISSN = ISSN { dict["ISSN"] = ISSN }
        dict["issue"] = issue
        if let jurisdiction = jurisdiction { dict["jurisdiction"] = jurisdiction }
        if let keyword = keyword { dict["keyword"] = keyword }
        if let language = language { dict["language"] = language }
        if let locator = locator { dict["locator"] = locator }
        if let medium = medium { dict["medium"] = medium }
        if let note = note { dict["note"] = note }
        dict["number"] = number
        dict["number-of-pages"] = numberOfPages
        dict["number-of-volumes"] = numberOfVolumes
        if let originalPublisher = originalPublisher { dict["original-publisher"] = originalPublisher }
        if let originalPublisherPlace = originalPublisherPlace { dict["original-publisher-place"] = originalPublisherPlace }
        if let originalTitle = originalTitle { dict["original-title"] = originalTitle }
        if let page = page { dict["page"] = page }
        if let pageFirst = pageFirst { dict["page-first"] = pageFirst }
        if let PMCID = PMCID { dict["PMCID"] = PMCID }
        if let PMID = PMID { dict["PMID"] = PMID }
        if let publisher = publisher { dict["publisher"] = publisher }
        if let publisherPlace = publisherPlace { dict["publisher-place"] = publisherPlace }
        if let recipient = recipient { dict["recipient"] = recipient }
        if let references = references { dict["references"] = references }
        if let reviewedAuthor = reviewedAuthor { dict["reviewed-author"] = reviewedAuthor }
        if let reviewedTitle = reviewedTitle { dict["reviewed-title"] = reviewedTitle }
        if let scale = scale { dict["scale"] = scale }
        if let section = section { dict["section"] = section }
        if let source = source { dict["source"] = source }
        if let status = status { dict["status"] = status }
        if let title = title { dict["title"] = title }
        if let titleShort = titleShort { dict["title-short"] = titleShort }
        if let translator = translator { dict["translator"] = translator }
        if let URL = URL { dict["URL"] = URL }
        if let version = version { dict["version"] = version }
        if let volume = volume { dict["volume"] = volume }
        if let yearSuffix = yearSuffix { dict["year-suffix"] = yearSuffix }
        if let institution = institution { dict["institution"] = institution }
        
        return dict
    }
}