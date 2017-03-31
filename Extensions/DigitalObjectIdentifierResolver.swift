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
    public let originatingString: String
    
    public init(originatingString: String) throws {
        guard (originatingString as NSString).isMatched(byRegex: type(of: self).capturingPattern()) else {
            throw ResolvingError.notResolvable("\(originatingString) does not look like a PDB ID.")
        }
        
        self.originatingString = originatingString
        self.identifier = self.originatingString
    }
    
    // from http://stackoverflow.com/questions/27910/finding-a-doi-in-a-document-or-page
    public static func capturingPattern() -> String { return "\\b(10[.][0-9]{4,}(?:[.][0-9]+)*/(?:(?![\"&\\'<>])[[:graph:]])+)\\b" }
}

public struct DigitalObjectIdentifierResolver: URLBasedResolver {
    
    fileprivate let _baseURL:URL
    public func baseURL() -> URL {
        return self._baseURL
    }
    
    public init(baseURL:URL = URL(string:"http://dx.doi.org")!) {
        self._baseURL = baseURL
    }
    
    public static let identifier: String = "org.doi.dx"
    
    public let resolvableType:Resolvable.Type = {
        return DigitalObjectIdentifier.self
    }()
    
    public func resolve(_ string: String) throws -> ResolvedResult {
        let DOI = try DigitalObjectIdentifier(originatingString:string)
        let items = try self.bibliographyItems(DOI: DOI)
        guard items.count > 0 else {
            return ResolvedResult(resolvable:DOI, result:.none)
        }
        
        return ResolvedResult(resolvable:DOI, result:.bibliographyItems(items))
    }
    
    fileprivate func bibliographyItems(DOI:DigitalObjectIdentifier) throws -> [BibliographyItem] {
        let baseURL = self.baseURL()
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw ResolvingError.invalidResolverURL(baseURL)
        }
        components.path = (components.path + "/") + DOI.identifier
        
        guard let queryURL = components.url else {
            throw ResolvingError.invalidResolverURLComponents(components)
        }
        
        var req = URLRequest(url: queryURL)
        req.setValue("application/citeproc+json", forHTTPHeaderField: "Accept")
        
        let response = try NSURLConnection.sendRateLimitedSynchronousRequest(req, rateLimitLabel: self.rateLimitLabel, rateLimit: self.rateLimit)
        
        guard response.statusCode.marksSuccess else {
            throw ResolvingError.unexpectedStatusCode(response.statusCode)
        }
        
        let json = try JSON(data: response.data)
        
        let item = try SimpleBibliographyItem(json: json)
        return [item]
    }
}
