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
        let uppercaseString = originatingString.uppercaseString
        
        let evaluatedID:String
        if !uppercaseString.hasPrefix("pmid:") {
            evaluatedID = "PMID:\(uppercaseString)"
        }
        else {
            evaluatedID = uppercaseString
        }
        
        guard (evaluatedID as NSString).isMatchedByRegex(self.dynamicType.capturingPattern()) else {
            throw ResolvingError.NotResolvable(evaluatedID)
        }
        
        self.originatingString = originatingString
        self.identifier = (evaluatedID as NSString).captureComponentsMatchedByRegex(self.dynamicType.contentCapturingPattern())[1] as! String
    }
    
    public static func capturingPattern() -> String {
        return "(PMID:\\d{1,20})"
    }
    private static func contentCapturingPattern() -> String {
        return "PMID:(\\d{1,20})"
    }
}

public class PubMedResolver: URLBasedResolver {
    
    public let resolvableType: Resolvable.Type = {
        return PubMedIdentifier.self
    }()
    
    private let _baseURL:NSURL
    
    
    public func baseURL() -> NSURL {
        return _baseURL
    }
    
    public init(baseURL:NSURL = NSURL(string: "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&rettype=xml")!) {
        self._baseURL = baseURL
    }
    
    public static var identifier:String = "gov.nih.nlm.ncbi.eutils"
    
    private func bibliographyItem(doc:XMLIndexer) throws -> BibliographyItem {
        let b = SimpleBibliographyItem()
        
        let articleSet = doc["PubmedArticleSet"]
        switch articleSet {
        case .XMLError(let error): throw error
        default: break
        }
        
        if articleSet.children.count == 0 {
            throw ResolvingError.NotResolvable(articleSet.description)
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
        
        if article.boolValue {
            b.title = article["ArticleTitle"].element?.text
            
            if article["Abstract"].children.count > 0 {
                b.abstract = article["Abstract"]["AbstractText"].element?.text                
            }
            
            if article["AuthorList"].boolValue {
                b.author = article["AuthorList"].children.map { author -> BibliographicName in
                    SimpleBibliographicName(family: author["LastName"].element?.text,
                                            given: author["ForeName"].element?.text,
                                            suffix: nil,
                                            droppingParticle: nil, nonDroppingParticle: nil, literal: nil)
                }
            }
            
            let journal = article["Journal"]
            if journal.boolValue {
                b.containerTitle = journal["Title"].element?.text
                b.ISSN = journal["ISSN"].element?.text
                
                let journalIssue = journal["JournalIssue"]
                if journalIssue.boolValue {
                    b.volume = journalIssue["Volume"].element?.text
                    if let issueTxt = journalIssue["Issue"].element?.text,
                        let issueNo = Int(issueTxt) {
                        b.issue = issueNo
                    }
                    
                    if journalIssue["PubDate"]["Year"].boolValue,
                        let year = journalIssue["PubDate"]["Year"].element?.text {
                        let date = SimpleBibliographicDate(dateParts: [[year]])
                        b.issued = date
                    }
                }
            }
        }
        
        return b
    }
    
    private func bibliographyItem(PMID:PubMedIdentifier) throws -> BibliographyItem {
        let baseURL = self.baseURL()
        guard let components = NSURLComponents(URL: baseURL, resolvingAgainstBaseURL: false) else {
            throw ResolvingError.InvalidResolverURL(baseURL)
        }
        
        guard let query = components.query else {
            throw ResolvingError.MissingQuery(components)
        }
        
        // append &id=… into the query
        components.query = query + "&id=\(PMID.identifier)"
        
        guard let queryURL = components.URL else {
            throw ResolvingError.InvalidResolverURLComponents(components)
        }
        
        let response = try NSURLConnection.sendRateLimitedSynchronousRequest(NSURLRequest(URL: queryURL),
                                                                             rateLimitLabel: self.rateLimitLabel,
                                                                             rateLimit: self.rateLimit)
        
        guard response.statusCode.marksSuccess else { throw ResolvingError.UnexpectedStatusCode(response.statusCode) }
        
        let doc = SWXMLHash.parse(response.data)
        
        return try self.bibliographyItem(doc)
    }
    
    public func resolve(identifier: String) throws -> ResolvedResult {
        let PMID = try PubMedIdentifier(originatingString: identifier)
        let bibItem = try self.bibliographyItem(PMID)
        return ResolvedResult(resolvable: PMID, result:.BibliographyItems([bibItem]))
    }
    
}
