//
//  SimpleBibliographyItem.swift
//  Extensions
//
//  Created by Matias Piipari on 20/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation
import Freddy

@objc public class SimpleBibliographyItem: NSObject, BibliographyItem, JSONDecodable, JSONEncodable {

    public var author: [BibliographicName]? = nil
    
    public var accessed: BibliographicDate? = nil
    
    public var eventDate: BibliographicDate? = nil
    
    public var submitted: BibliographicDate? = nil
    
    public var issued: BibliographicDate? = nil

    public var originalDate: BibliographicDate? = nil
    
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
    
    public func toJSON() -> JSON {
        let data = try! NSJSONSerialization.dataWithJSONObject(self.dictionaryRepresentation, options: [])
        return try! JSON(data:data)
    }
    
    public override init() {
        super.init()
    }
    
    public required init(json: JSON) throws {
        do { self.author = try json.arrayOf("author", alongPath:[.MissingKeyBecomesNil], type:SimpleBibliographicName.self) } catch { }
        do { self.accessed = try json.decode("accessed", alongPath:[.MissingKeyBecomesNil], type:SimpleBibliographicDate.self) } catch { }
        do { self.eventDate = try json.decode("event-date", alongPath:[.MissingKeyBecomesNil], type:SimpleBibliographicDate.self) } catch { }
        do { self.submitted = try json.decode("submitted", alongPath:[.MissingKeyBecomesNil], type:SimpleBibliographicDate.self) } catch { }
        do { self.issued = try json.decode("issued", alongPath:[.MissingKeyBecomesNil], type:SimpleBibliographicDate.self) } catch { }
        do { self.originalDate = try json.decode("original-date", alongPath:[.MissingKeyBecomesNil], type:SimpleBibliographicDate.self) } catch { }
        
        do { self.abstract = try json.string("abstract", alongPath: [.MissingKeyBecomesNil]) } catch {}

        do { self.annote = try json.string("annote", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.archive = try json.string("archive", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.archiveLocation = try json.string("archive-location", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.archivePlace = try json.string("archive-place", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.authority = try json.string("authority", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.callNumber = try json.string("call-number", alongPath: [.MissingKeyBecomesNil]) } catch {}
        
        do {
            if let chapterNumber = Int(try json.string("chapter-number")) {
                self.chapterNumber = chapterNumber
            }
        } catch {}
        
        do { self.citationLabel = try json.string("citation-label", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.collectionEditor = try json.string("collection-editor", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.collectionNumber = try json.string("collection-number", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.collectionTitle = try json.string("collection-title", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.composer = try json.string("composer", alongPath: [.MissingKeyBecomesNil]) } catch {}
        
        do { self.containerAuthor = try json.string("container-author", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.containerTitle = try json.string("container-title", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.containerTitleShort = try json.string("container-title-short", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.dimensions = try json.string("dimensions", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.director = try json.string("director", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.DOI = try json.string("DOI", alongPath: [.MissingKeyBecomesNil]) } catch {}
        
        do {
            if let edition = Int(try json.string("edition")) {
                self.edition = edition
            }
        } catch {}
        
        do { self.editor = try json.string("editor", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.editorialDirector = try json.string("editorial-director", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.event = try json.string("event", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.eventPlace = try json.string("event-place", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.genre = try json.string("genre", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.illustrator = try json.string("illustrator", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.interviewer = try json.string("interviewer", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.ISBN = try json.string("ISBN", alongPath: [.MissingKeyBecomesNil]) } catch {}
        
        do {
            self.ISSN = try json.string("ISSN", alongPath: [.MissingKeyBecomesNil])
        }
        catch {
            do { self.ISSN = try json.array("ISSN", alongPath: [.MissingKeyBecomesNil])?.first?.decode(type:String.self) }
            catch { }
        }

        do {
            if let issue = Int(try json.string(issue)) {
                self.issue = issue
            }
        } catch {}
            
        do { self.jurisdiction = try json.string("jurisdiction", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.keyword = try json.string("keyword", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.language = try json.string("language", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.locator = try json.string("locator", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.medium = try json.string("medium", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.note = try json.string("note", alongPath: [.MissingKeyBecomesNil]) } catch {}
        
        do { if let number = Int(try json.string("number")) { self.number = number } } catch {}
        do { if let numberOfPages = Int(try json.string("number-of-pages")) { self.numberOfPages = numberOfPages } } catch {}
        do { if let numberOfVolumes = Int(try json.string("number-of-volumes")) { self.numberOfVolumes = numberOfVolumes } } catch {}
        
        do { self.originalPublisher = try json.string("original-publisher", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.originalPublisherPlace = try json.string("original-publisher-place", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.originalTitle = try json.string("original-title", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.page = try json.string("page", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.pageFirst = try json.string("page-first", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.PMCID = try json.string("PMCID", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.PMID = try json.string("PMID", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.publisher = try json.string("publisher", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.publisherPlace = try json.string("publisher-place", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.recipient = try json.string("recipient", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.references = try json.string("references", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.reviewedAuthor = try json.string("reviewed-author", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.reviewedTitle = try json.string("reviewed-title", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.scale = try json.string("scale", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.section = try json.string("section", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.source = try json.string("source", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.status = try json.string("status", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.title = try json.string("title", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.titleShort = try json.string("title-short", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.translator = try json.string("translator", alongPath: [.MissingKeyBecomesNil]) } catch {}
        
        do {
            if let url = NSURL(string:try json.string("URL")) {
                self.URL = url
            }
        } catch {}
            
        do { self.version = try json.string("version", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.volume = try json.string("volume", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.yearSuffix = try json.string("year-suffix", alongPath: [.MissingKeyBecomesNil]) } catch {}
        do { self.institution = try json.string("institution", alongPath: [.MissingKeyBecomesNil]) } catch {}
    }
    
    deinit {
        
    }
    
    public var dictionaryRepresentation:[String : AnyObject] {
        var dict = [String:AnyObject]()
        
        if let authors = self.author {
            let authorDicts = authors.map { $0.dictionaryRepresentation }
            dict["author"] = authorDicts
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
        if let URL = URL { dict["URL"] = URL.absoluteString }
        if let version = version { dict["version"] = version }
        if let volume = volume { dict["volume"] = volume }
        if let yearSuffix = yearSuffix { dict["year-suffix"] = yearSuffix }
        if let institution = institution { dict["institution"] = institution }
        
        return dict
    }
    
    public var tagName:String {
        return "span"
    }
    
    public var innerHTML:String {
        if let citationLabel = self.citationLabel {
            return "\(citationLabel)"
        }
        else if let author = self.author?.first where author.family != nil {
            var str = "\(author.family)"
            
            let authorCount = self.author?.count
            
            if authorCount == 2 {
                if let secondAuthor = self.author?[1] where secondAuthor.family != nil {
                    str += " & \(secondAuthor.family)"
                }
            }
            else if authorCount > 2 {
                str += " et al."
            }
            
            if let issuedDate = self.issued {
                if let dateParts = issuedDate.dateParts where dateParts.count > 0 {
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
    
    public var attributes: [String : String] {
        return [:]
    }
}