//
//  BibliographyItem.swift
//  Extensions
//
//  Created by Matias Piipari on 20/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation
import Freddy

public protocol BibliographyItemObject: class, BibliographyItem {
    
}

public protocol BibliographyItem: DictionaryRepresentable, HTMLSnippetRepresentable, CustomStringConvertible {
    // Abstract of the item (e.g. the abstract of a journal article).
    var abstract:String? { get }

    ///** Date the item has been accessed */
    var accessed:BibliographicDate? { get }

    // Reader's notes about the item content.
    var annote:String? { get }

    // Archive storing the item.
    var archive:String? { get }
    
    // Storage location within an archive (e.g. a box and folder number) - backed by key 'archive_location'.
    var archiveLocation:String? { get }

    // Geographic location of the archive.
    var archivePlace:String? { get }

    // Author names.
    var author:[BibliographicName]? { get }

    // Issuing or judicial authority (e.g. "USPTO" for a patent, "Fairfax Circuit Court" for a legal case).
    var authority:String? { get }

    // Call number (to locate the item in a library) - backed by key 'call-number'.
    var callNumber:String? { get }

    // Chapter number - backed by key 'chapter-number'.
    var chapterNumber:Int { get }

    // Label identifying the item in in-text citations of label styles (e.g. "Ferr78"). May be assigned by the CSL processor based on item metadata - backed by key 'citation-label' */
    var citationLabel:String? { get }

    // Editor of the collection holding the item (e.g. the series editor for a book) - backed by key 'collection-editor'.
    var collectionEditor:String? { get }

    // Number identifying the collection holding the item (e.g. the series number for a book). */
    var collectionNumber:String? { get }

    // Title of the collection holding the item (e.g. the series title for a book).
    var collectionTitle:String? { get }

    // Composer name (e.g. of a musical score).
    var composer:String? { get }

    // Author of the container holding the item (e.g. the book author for a book chapter).
    var containerAuthor:String? { get }
    
    // Title of the container holding the item (e.g. the book title for a book chapter, the journal title for a journal article) - backed by key 'container-title'.
    var containerTitle:String? { get }
    
    // Short/abbreviated form of "container-title" (also accessible through the "short" form of the "container-title" variable).
    var containerTitleShort:String? { get }

    // Physical (e.g. size) or temporal (e.g. running time) dimensions of the item.
    var dimensions:String? { get }

    // Director (e.g. of a film).
    var director:String? { get }
    
    // Digital Object Identifier (e.g. "10.1128/AEM.02591-07").
    var DOI:String? { get }
    
    // Edition holding the item (e.g. "3" when citing a chapter in the third edition of a book).
    var edition:Int { get }

    // Editor name.
    var editor:String? { get }

    // Managing editor ("Directeur de la Publication" in French).
    var editorialDirector:String? { get }

    // event Name of the related event (e.g. the conference name when citing a conference paper).
    var event:String? { get }

    // Date the related event took place.
    var eventDate:BibliographicDate? { get }

    // Geographic location of the related event (e.g. "Amsterdam, the Netherlands") - backed by key 'event-place'.
    var eventPlace:String? { get }

    // Type or genre of the item (e.g. "adventure" for an adventure movie, "PhD dissertation" for a PhD thesis) */
    var genre:String? { get }

    // Illustrator name (e.g. of a children's book).
    var illustrator:String? { get }

    // Interviewer name (e.g. of an interview).
    var interviewer:String? { get }

    // International Standard Book Number.
    var ISBN:String? { get }

    // ISSN International Standard Serial Number.
    var ISSN:String? { get }

    // Issue holding the item (e.g. "5" when citing a journal article from journal volume 2, issue 5).
    var issue:Int { get }

    // Date the item was issued/published.
    var issued:BibliographicDate? { get }

    // Geographic scope of relevance (e.g. "US" for a US patent).
    var jurisdiction:String? { get }

    // keyword(s) or tag(s) attached to the item.
    var keyword:String? { get }

    // Language code. Not intended for display purposes.
    var language:String? { get }

    // A cite-specific pinpointer within the item (e.g. a page number within a book, or a volume in a multi-volume work). Must be accompanied in the input data by a label indicating the locator type (see the Locators term list), which determines which term is rendered by cs:label when the "locator" variable is selected.
    var locator:String? { get }

    // Medium description (e.g. "CD", "DVD", etc.)
    var medium:String? { get}

    // Note giving additional item details (e.g. a concise summary or commentary).
    var note:String? { get }
    
    // Number identifying the item (e.g. a report number).
    var number:Int { get }

    // Total number of pages of the cited item. - backed by 'number-of-pages'.
    var numberOfPages:Int { get }

    // Total number of volumes, usable for citing multi-volume books and such - backed by 'number-of-volumes' */
    var numberOfVolumes:Int { get }

    // Date of the original version - backed by 'original-date' */
    var originalDate:BibliographicDate? { get }

    // Original publisher, for items that have been republished by a different publisher - backed by 'original-publisher'.
    var originalPublisher:String? { get }

    // Geographic location of the original publisher (e.g. "London, UK") - backed by 'original-publisher-place'.
    var originalPublisherPlace:String? { get }

    // Title of the original version (e.g. "Война и мир", the untranslated Russian title of "War and Peace") - backed by 'original-title'.
    var originalTitle:String? { get }

    // Range of pages the item (e.g. a journal article) covers in a container (e.g. a journal issue).
    var page:String? { get }

    // first page of the range of pages the item (e.g. a journal article) covers in a container (e.g. a journal issue) - backed by 'page-first'.
    var pageFirst:String? { get }

    // PubMed Central reference number.
    var PMCID:String? { get }

    // PubMed reference number.
    var PMID:String? { get }

    // Publisher name.
    var publisher:String? { get }

    // Geographic location of the publisher.
    var publisherPlace:String? { get }

    // Recipient name (e.g. of a letter).
    var recipient:String? { get }

    // Resources related to the procedural history of a legal case.
    var references:String? { get }

    /** Author of the item reviewed by the current item - backed by 'reviewed-author'.
    var reviewedAuthor:String? { get }

    // Title of the item reviewed by the current item - backed by 'reviewed-title'.
    var reviewedTitle:String? { get }

    // Scale of e.g. a map */
    var scale:String? { get }

    // Section	[standard] container section holding the item (e.g. "politics" for a newspaper article).
    var section:String? { get }

    // Source from whence the item originates (e.g. a library catalog or database) */
    var source:String? { get }

    // status	[standard] (publication) status of the item (e.g. "forthcoming").
    var status:String? { get }

    // Date the item (e.g. a manuscript) has been submitted for publication.
    var submitted:BibliographicDate? { get }

    // title	[standard] primary title of the item.
    var title:String? { get }

    // Short/abbreviated form of "title" (also accessible through the "short" form of the "title" variable) - backed by 'title-short'.
    var titleShort:String? { get }

    // Translator name.
    var translator:String? { get }

    // URL	[standard] Uniform Resource Locator (e.g. "http://aem.asm.org/cgi/content/full/74/9/2766").
    var URL:Foundation.URL? { get }

    // version	[standard] version of the item (e.g. "2.0.9" for a software program).
    var version:String? { get }

    // Volume holding the item (e.g. "2" when citing a chapter from book volume 2).
    var volume:String? { get }

    // Disambiguating year suffix in author-date styles (e.g. "a" in "Doe, 1999a") - backed by 'year-suffix'.
    var yearSuffix:String? { get }

    // Specifies the type (the accepted field set) of the bibliography item.
    //var bibliographyItemType:MPBibliographyItemFieldSet? { get }

    //var inferredBibliographyItemType:MPBibliographyItemFieldSet? { get }
    //@property (readonly, nonnull)  *;

    // Affiliated institution for the record.
    var institution:String? { get }

    // MARK -

    // An identifier for the source format (reverse domain notated UTI string for the format).
    //var sourceUTI:String? { get }

    // An identifier for the originating source (e.g. bundle identifier for application, if available).
    //var sourceIdentifier:String? { get }

    // An identifier for the object at its source (to allow recognising a record for re-importing if it has changed).
    //var originalIdentifier:String? { get }

    // A hash of the contents of the original data.
    //var originalDataChecksum:String? { get }

    // The original data that was imported to create the bibliography item.
    //@property (readwrite, nullable) NSData *originalData;

    // The value of 'entrytype' string when importing BibTeX. */
    // @property (readwrite, nullable) NSString *entryType;
}
