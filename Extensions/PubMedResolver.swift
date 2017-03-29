//
//  PubMedClient.swift
//  Extensions
//
//  Created by Matias Piipari on 20/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation
import RegexKitLite
import SWXMLHash

public struct PubMedIdentifier: Resolvable {
    public let identifier: String
    public let originatingString: String
    
    public init(originatingString: String) throws {
        let uppercaseString = originatingString.uppercased()
        
        let evaluatedID:String
        if !uppercaseString.hasPrefix("pmid:") {
            evaluatedID = "PMID:\(uppercaseString)"
        }
        else {
            evaluatedID = uppercaseString
        }
        
        guard (evaluatedID as NSString).isMatched(byRegex: type(of: self).capturingPattern()) else {
            throw ResolvingError.notResolvable(evaluatedID)
        }
        
        self.originatingString = originatingString
        self.identifier = (evaluatedID as NSString).captureComponentsMatched(byRegex: type(of: self).contentCapturingPattern())[1] as! String
    }
    
    public static func capturingPattern() -> String {
        return "(PMID:\\d{1,20})"
    }
    fileprivate static func contentCapturingPattern() -> String {
        return "PMID:(\\d{1,20})"
    }
}

open class PubMedResolver: URLBasedResolver {
    
    open let resolvableType: Resolvable.Type = {
        return PubMedIdentifier.self
    }()
    
    fileprivate let _baseURL:URL
    
    
    open func baseURL() -> URL {
        return _baseURL
    }
    
    public init(baseURL:URL = URL(string: "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&rettype=xml")!) {
        self._baseURL = baseURL
    }
    
    open static var identifier:String = "gov.nih.nlm.ncbi.eutils"
    
    fileprivate func bibliographyItem(_ doc:XMLIndexer) throws -> BibliographyItem {
        let b = SimpleBibliographyItem()
        
        let articleSet = doc["PubmedArticleSet"]
        switch articleSet {
        case .XMLError(let error): throw error
        default: break
        }
        
        if articleSet.children.count == 0 {
            throw ResolvingError.notResolvable(articleSet.description)
        }
        
        let pubmedArticle = articleSet["PubmedArticle"]
        switch articleSet {
        case .XMLError(let error): throw error
        default: break
        }
        
        let citation = pubmedArticle["MedlineCitation"]
        switch citation {
            case .XMLError(let error): throw error
            default: break
        }
        
        b.PMID = citation["PMID"].element?.text
        
        let article = citation["Article"]
        
        if article.element != nil {
            b.title = article["ArticleTitle"].element?.text
            
            if article["Abstract"].children.count > 0 {
                b.abstract = article["Abstract"]["AbstractText"].element?.text                
            }
            
            if article["AuthorList"].element != nil {
                b.author = article["AuthorList"].children.map { author -> BibliographicName in
                    SimpleBibliographicName(family: author["LastName"].element?.text,
                                            given: author["ForeName"].element?.text,
                                            suffix: nil,
                                            droppingParticle: nil, nonDroppingParticle: nil, literal: nil)
                }
            }
            
            let journal = article["Journal"]
            if journal.element != nil {
                b.containerTitle = journal["Title"].element?.text
                b.ISSN = journal["ISSN"].element?.text
                
                let journalIssue = journal["JournalIssue"]
                
                if journalIssue.element != nil {
                    b.volume = journalIssue["Volume"].element?.text
                    if let issueTxt = journalIssue["Issue"].element?.text,
                        let issueNo = Int(issueTxt) {
                        b.issue = issueNo
                    }
                    
                    if journalIssue["PubDate"]["Year"].element != nil,
                        let year = journalIssue["PubDate"]["Year"].element?.text {
                        let date = SimpleBibliographicDate(dateParts: [[year]])
                        b.issued = date
                    }
                }
            }
        }
        
        return b
    }
    
    fileprivate func bibliographyItem(_ PMID:PubMedIdentifier) throws -> BibliographyItem {
        let baseURL = self.baseURL()
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw ResolvingError.invalidResolverURL(baseURL)
        }
        
        guard let query = components.query else {
            throw ResolvingError.missingQuery(components)
        }
        
        // append &id=… into the query
        components.query = query + "&id=\(PMID.identifier)"
        
        guard let queryURL = components.url else {
            throw ResolvingError.invalidResolverURLComponents(components)
        }
        
        let response = try NSURLConnection.sendRateLimitedSynchronousRequest(URLRequest(url: queryURL),
                                                                             rateLimitLabel: self.rateLimitLabel,
                                                                             rateLimit: self.rateLimit)
        
        guard response.statusCode.marksSuccess else { throw ResolvingError.unexpectedStatusCode(response.statusCode) }
        
        let doc = SWXMLHash.parse(response.data)
        
        return try self.bibliographyItem(doc)
    }
    
    open func resolve(_ identifier: String) throws -> ResolvedResult {
        let PMID = try PubMedIdentifier(originatingString: identifier)
        let bibItem = try self.bibliographyItem(PMID)
        return ResolvedResult(resolvable: PMID, result:.bibliographyItems([bibItem]))
    }
    
}
