//
//  DigitalObjectIdentifierResolver.swift
//  Extensions
//
//  Created by Matias Piipari on 23/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

public struct DigitalObjectIdentifier:Resolvable {
    public let identifier:String
    
    public init(identifier: String) throws {
        guard (identifier as NSString).isMatchedByRegex("\\b(10[.][0-9]{4,}(?:[.][0-9]+)*/(?:(?![\"&\\'<>])[[:graph:]])+)\\b") else {
            throw ResolvingError.NotResolvable("\(identifier) does not look like a PDB ID.")
        }
        
        self.identifier = identifier
    }
}

public struct DigitalObjectIdentifierResolver:Resolver {
    
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
        let items = try self.bibliographyItems(DOI: DigitalObjectIdentifier(identifier:identifier))
        guard items.count > 0 else {
            return ResolvedResult.None
        }
        
        return ResolvedResult.BibliographyItems(items)
    }
    
    private func bibliographyItems(DOI DOI:DigitalObjectIdentifier) throws -> [BibliographyItem] {
        let baseURL = self.baseURL()
        guard let components = NSURLComponents(URL: baseURL, resolvingAgainstBaseURL: false) else {
            throw ResolvingError.InvalidResolverURL(baseURL)
        }
        components.path = components.path?.stringByAppendingString(DOI.identifier)
        
        guard let queryURL = components.URL else {
            throw ResolvingError.InvalidResolverURLComponents(components)
        }
        
        let response = try NSURLConnection.sendSynchronousRequest(NSURLRequest(URL: queryURL))
        
        guard response.statusCode.marksSuccess else {
            throw ResolvingError.UnexpectedStatusCode(response.statusCode)
        }
        
        return []
    }
}