//
//  DigitalObjectIdentifierResolver.swift
//  Extensions
//
//  Created by Matias Piipari on 23/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation
import Freddy

public struct DigitalObjectIdentifier:Resolvable {
    public let identifier:String
    
    public init(identifier: String) throws {
        guard (identifier as NSString).isMatchedByRegex(self.dynamicType.capturingPattern()) else {
            throw ResolvingError.NotResolvable("\(identifier) does not look like a PDB ID.")
        }
        
        self.identifier = identifier
    }
    
    // from http://stackoverflow.com/questions/27910/finding-a-doi-in-a-document-or-page
    public static func capturingPattern() -> String { return "\\b(10[.][0-9]{4,}(?:[.][0-9]+)*/(?:(?![\"&\\'<>])[[:graph:]])+)\\b" }
}

public struct DigitalObjectIdentifierResolver: URLBasedResolver {
    
    private let _baseURL:NSURL
    public func baseURL() -> NSURL {
        return self._baseURL
    }
    
    public init(baseURL:NSURL = NSURL(string:"http://dx.doi.org")!) {
        self._baseURL = baseURL
    }
    
    public let resolvableType:Resolvable.Type = {
        return DigitalObjectIdentifier.self
    }()
    
    public func resolve(identifier: String) throws -> ResolvedResult {
        let DOI = try DigitalObjectIdentifier(identifier:identifier)
        let items = try self.bibliographyItems(DOI: DOI)
        guard items.count > 0 else {
            return ResolvedResult.None(DOI)
        }
        
        return ResolvedResult.BibliographyItems(DOI, items)
    }
    
    private func bibliographyItems(DOI DOI:DigitalObjectIdentifier) throws -> [BibliographyItem] {
        let baseURL = self.baseURL()
        guard let components = NSURLComponents(URL: baseURL, resolvingAgainstBaseURL: false) else {
            throw ResolvingError.InvalidResolverURL(baseURL)
        }
        components.path = components.path?.stringByAppendingString("/").stringByAppendingString(DOI.identifier)
        
        guard let queryURL = components.URL else {
            throw ResolvingError.InvalidResolverURLComponents(components)
        }
        
        let req = NSMutableURLRequest(URL: queryURL)
        req.setValue("application/citeproc+json", forHTTPHeaderField: "Accept")
        
        let response = try NSURLConnection.sendRateLimitedSynchronousRequest(req, rateLimitLabel: self.rateLimitLabel, rateLimit: self.rateLimit)
        
        guard response.statusCode.marksSuccess else {
            throw ResolvingError.UnexpectedStatusCode(response.statusCode)
        }
        
        let json = try JSON(data: response.data)
        
        let item = try SimpleBibliographyItem(json: json)
        return [item]
    }
}