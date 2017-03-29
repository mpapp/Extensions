//
//  SimpleBibliographyItem.swift
//  Extensions
//
//  Created by Matias Piipari on 20/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation
import Freddy

@objc open class SimpleBibliographyItem: NSObject, BibliographyItem, JSONDecodable, JSONEncodable {

    open var author: [BibliographicName]? = nil
    
    open var accessed: BibliographicDate? = nil
    
    open var eventDate: BibliographicDate? = nil
    
    open var submitted: BibliographicDate? = nil
    
    open var issued: BibliographicDate? = nil

    open var originalDate: BibliographicDate? = nil
    
    open var abstract:String? = nil
    
    open var annote:String? = nil
    
    open var archive:String? = nil
    
    open var archiveLocation:String? = nil
    
    open var archivePlace:String? = nil
    
    open var authority:String? = nil
    
    open var callNumber:String? = nil
    
    open var chapterNumber:Int = 0
    
    open var citationLabel:String? = nil
    
    open var collectionEditor:String? = nil
    
    open var collectionNumber:String? = nil
    
    open var collectionTitle:String? = nil
    
    open var composer:String? = nil
    
    open var containerAuthor:String? = nil
    
    open var containerTitle:String? = nil
    
    open var containerTitleShort:String? = nil
    
    open var dimensions:String? = nil
    
    open var director:String? = nil
    
    open var DOI:String? = nil
    
    open var edition:Int = 0
    
    open var editor:String? = nil
    
    open var editorialDirector:String? = nil
    
    open var event:String? = nil
    
    open var eventPlace:String? = nil
    
    open var genre:String? = nil
    
    open var illustrator:String? = nil
    
    open var interviewer:String? = nil
    
    open var ISBN:String? = nil
    
    open var ISSN:String? = nil
    
    open var issue:Int = 0
    
    open var jurisdiction:String? = nil
    
    open var keyword:String? = nil
    
    open var language:String? = nil
    
    open var locator:String? = nil
    
    open var medium:String? = nil
    
    open var note:String? = nil
    
    open var number:Int = 0
    
    open var numberOfPages:Int = 0
    
    open var numberOfVolumes:Int = 0
    
    open var originalPublisher:String? = nil
    
    open var originalPublisherPlace:String? = nil
    
    open var originalTitle:String? = nil
    
    open var page:String? = nil
    
    open var pageFirst:String? = nil
    
    open var PMCID:String? = nil
    
    open var PMID:String? = nil
    
    open var publisher:String? = nil
    
    open var publisherPlace:String? = nil
    
    open var recipient:String? = nil
    
    open var references:String? = nil
    
    open var reviewedAuthor:String? = nil
    
    open var reviewedTitle:String? = nil
     
    open var scale:String? = nil
    
    open var section:String? = nil
    
    open var source:String? = nil
    
    open var status:String? = nil
    
    open var title:String? = nil
    
    open var titleShort:String? = nil
    
    open var translator:String? = nil
    
    open var URL:Foundation.URL? = nil
    
    open var version:String? = nil
    
    open var volume:String? = nil
    
    open var yearSuffix:String? = nil
    
    open var institution:String? = nil
    
    open func toJSON() -> JSON {
        let data = try! JSONSerialization.data(withJSONObject: self.dictionaryRepresentation, options: [])
        return try! JSON(data:data)
    }
    
    public override init() {
        super.init()
    }
    
    public required init(json: JSON) throws {

        do { self.author = try json.decodedArray(at: "author", alongPath:[.missingKeyBecomesNil], type:SimpleBibliographicName.self) } catch { }
        do { self.accessed = try json.decode(at: "accessed", alongPath:[.missingKeyBecomesNil], type:SimpleBibliographicDate.self) } catch { }
        do { self.eventDate = try json.decode(at: "event-date", alongPath:[.missingKeyBecomesNil], type:SimpleBibliographicDate.self) } catch { }
        do { self.submitted = try json.decode(at: "submitted", alongPath:[.missingKeyBecomesNil], type:SimpleBibliographicDate.self) } catch { }
        do { self.issued = try json.decode(at: "issued", alongPath:[.missingKeyBecomesNil], type:SimpleBibliographicDate.self) } catch { }
        do { self.originalDate = try json.decode(at: "original-date", alongPath:[.missingKeyBecomesNil], type:SimpleBibliographicDate.self) } catch { }
        
        do { self.abstract = try json.getString(at: "abstract", alongPath: [.missingKeyBecomesNil]) } catch {}

        do { self.annote = try json.getString(at: "annote", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.archive = try json.getString(at: "archive", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.archiveLocation = try json.getString(at: "archive-location", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.archivePlace = try json.getString(at: "archive-place", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.authority = try json.getString(at: "authority", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.callNumber = try json.getString(at: "call-number", alongPath: [.missingKeyBecomesNil]) } catch {}
        
        do {
            if let chapterNumber = Int(try json.getString(at: "chapter-number")) {
                self.chapterNumber = chapterNumber
            }
        } catch {}
        
        do { self.citationLabel = try json.getString(at: "citation-label", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.collectionEditor = try json.getString(at: "collection-editor", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.collectionNumber = try json.getString(at: "collection-number", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.collectionTitle = try json.getString(at: "collection-title", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.composer = try json.getString(at: "composer", alongPath: [.missingKeyBecomesNil]) } catch {}
        
        do { self.containerAuthor = try json.getString(at: "container-author", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.containerTitle = try json.getString(at: "container-title", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.containerTitleShort = try json.getString(at: "container-title-short", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.dimensions = try json.getString(at: "dimensions", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.director = try json.getString(at: "director", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.DOI = try json.getString(at: "DOI", alongPath: [.missingKeyBecomesNil]) } catch {}
        
        do {
            if let edition = Int(try json.getString(at: "edition")) {
                self.edition = edition
            }
        } catch {}
        
        do { self.editor = try json.getString(at: "editor", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.editorialDirector = try json.getString(at: "editorial-director", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.event = try json.getString(at: "event", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.eventPlace = try json.getString(at: "event-place", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.genre = try json.getString(at: "genre", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.illustrator = try json.getString(at: "illustrator", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.interviewer = try json.getString(at: "interviewer", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.ISBN = try json.getString(at: "ISBN", alongPath: [.missingKeyBecomesNil]) } catch {}
        
        do {
            self.ISSN = try json.getString(at: "ISSN", alongPath: [.missingKeyBecomesNil])
        }
        catch {
            do { self.ISSN = try json.getArray(at: "ISSN", alongPath: [.missingKeyBecomesNil])?.first?.decode(type:String.self) }
            catch { }
        }

        do { if let issue = Int(try json.getString(at: "issue")) { self.issue = issue } } catch {}
            
        do { self.jurisdiction = try json.getString(at: "jurisdiction", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.keyword = try json.getString(at: "keyword", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.language = try json.getString(at: "language", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.locator = try json.getString(at: "locator", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.medium = try json.getString(at: "medium", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.note = try json.getString(at: "note", alongPath: [.missingKeyBecomesNil]) } catch {}
        
        do { if let number = Int(try json.getString(at: "number")) { self.number = number } } catch {}
        do { if let numberOfPages = Int(try json.getString(at: "number-of-pages")) { self.numberOfPages = numberOfPages } } catch {}
        do { if let numberOfVolumes = Int(try json.getString(at: "number-of-volumes")) { self.numberOfVolumes = numberOfVolumes } } catch {}
        
        do { self.originalPublisher = try json.getString(at: "original-publisher", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.originalPublisherPlace = try json.getString(at: "original-publisher-place", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.originalTitle = try json.getString(at: "original-title", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.page = try json.getString(at: "page", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.pageFirst = try json.getString(at: "page-first", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.PMCID = try json.getString(at: "PMCID", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.PMID = try json.getString(at: "PMID", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.publisher = try json.getString(at: "publisher", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.publisherPlace = try json.getString(at: "publisher-place", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.recipient = try json.getString(at: "recipient", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.references = try json.getString(at: "references", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.reviewedAuthor = try json.getString(at: "reviewed-author", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.reviewedTitle = try json.getString(at: "reviewed-title", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.scale = try json.getString(at: "scale", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.section = try json.getString(at: "section", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.source = try json.getString(at: "source", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.status = try json.getString(at: "status", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.title = try json.getString(at: "title", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.titleShort = try json.getString(at: "title-short", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.translator = try json.getString(at: "translator", alongPath: [.missingKeyBecomesNil]) } catch {}
        
        do {
            if let url = Foundation.URL(string:try json.getString(at: "URL")) {
                self.URL = url
            }
        } catch {}
            
        do { self.version = try json.getString(at: "version", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.volume = try json.getString(at: "volume", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.yearSuffix = try json.getString(at: "year-suffix", alongPath: [.missingKeyBecomesNil]) } catch {}
        do { self.institution = try json.getString(at: "institution", alongPath: [.missingKeyBecomesNil]) } catch {}
    }
    
    deinit {
        
    }
    
    open var dictionaryRepresentation:[String : Any] {
        var dict = [String:Any]()
        
        if let authors = self.author {
            let authorDicts = authors.map { $0.dictionaryRepresentation }
            dict["author"] = authorDicts as AnyObject?
        }
        
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
        if let composer = self.composer { dict["composer"] = composer as AnyObject? }
        
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
        if let URL = URL { dict["URL"] = URL.absoluteString }
        if let version = version { dict["version"] = version }
        if let volume = volume { dict["volume"] = volume }
        if let yearSuffix = yearSuffix { dict["year-suffix"] = yearSuffix }
        if let institution = institution { dict["institution"] = institution }
        if let issued = issued { dict["issued"] = issued.dictionaryRepresentation }
        
        return dict
    }
    
    open var tagName:String {
        return "span"
    }
    
    open var innerHTML:String {
        if let citationLabel = self.citationLabel {
            return "\(citationLabel)"
        }
        else if let author = self.author?.first, author.family != nil {
            var str = "\(author.family)"
            
            if let authorCount = self.author?.count {
                if authorCount == 2 {
                    if let secondAuthor = self.author?[1], secondAuthor.family != nil {
                        str += " & \(secondAuthor.family)"
                    }
                }
                else if authorCount > 2 {
                    str += " et al."
                }
            }
            
            if let issuedDate = self.issued {
                if let dateParts = issuedDate.dateParts, dateParts.count > 0 {
                    str += " (\(dateParts.first))"
                }
                else if let literal = issuedDate.literal {
                    str += " (\(literal))"
                }
                else if let raw = issuedDate.raw {
                    str += " (\(raw))"
                }
            }
            
            return str
        }
        
        return "Unknown"
    }
    
    open var attributes: [String : String] {
        return [:]
    }
}
