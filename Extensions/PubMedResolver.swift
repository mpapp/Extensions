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
    
    public init(identifier: String) throws {
        let lowercaseID = identifier.lowercaseString
        
        let evaluatedID:String
        if lowercaseID.hasPrefix("pmid:") {
            evaluatedID = lowercaseID.stringByReplacingOccurrencesOfRegex("^pmid:", withString: "")
        }
        else {
            evaluatedID = lowercaseID
        }
        
        guard (evaluatedID as NSString).isMatchedByRegex(self.dynamicType.capturingPattern()) else {
            throw ResolvingError.NotResolvable(evaluatedID)
        }
        
        self.identifier = evaluatedID
    }
    
    public static func capturingPattern() -> String { return "^(\\d{1,20})$" }
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
    
    private func bibliographyItem(doc:XMLIndexer) throws -> BibliographyItem {
        let b = SimpleBibliographyItem()
        
        let citation = doc["PubmedArticleSet"]["PubmedArticle"]["MedlineCitation"]
        
        switch citation {
            case .XMLError(let error): throw error
            default: break
        }
        
        b.PMID = citation["PMID"].element?.text
        
        let article = citation["Article"]
        
        if article.boolValue {
            b.title = article["ArticleTitle"].element?.text
            b.abstract = article["Abstract"]["AbstractText"].element?.text
            
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
        let PMID = try PubMedIdentifier(identifier: identifier)
        let bibItem = try self.bibliographyItem(PMID)
        return ResolvedResult(resolvable: PMID, result:.BibliographyItems([bibItem]))
    }
    
}