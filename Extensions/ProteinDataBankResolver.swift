//
//  PDBClient.swift
//  Extensions
//
//  Created by Matias Piipari on 20/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation
import RegexKitLite
import Alamofire
import Freddy
import SWXMLHash

public struct ProteinDataBankIdentifier:Resolvable {
    public let identifier:String
    
    public init(identifier: String) throws {
        guard identifier.isUpper() else {
            throw ResolvingError.NotResolvable("\(identifier) contains lowercase characters and therefore cannot be a PDB ID.")
        }
        
        guard (identifier as NSString).isMatchedByRegex("[\\S,\\d]{4,4}") else {
            throw ResolvingError.NotResolvable("\(identifier) does not look like a PDB ID.")
        }
        
        self.identifier = identifier
    }
}

public struct ProteinDataBankResolver:Resolver {
    
    private let _baseURL:NSURL
    public func baseURL() -> NSURL {
        return self._baseURL
    }
    
    public init(baseURL:NSURL = NSURL(string:"http://www.rcsb.org/pdb/rest/describePDB")!) {
        self._baseURL = baseURL
    }
    
    public let resolvableType:Resolvable.Type = {
        return ProteinDataBankIdentifier.self
    }()
    
    public func resolve(identifier: String) throws -> ResolvedResult {
        let items = try self.bibliographyItems(proteinDataID: identifier)
        guard items.count > 0 else {
            return ResolvedResult.None
        }
        
        return ResolvedResult.BibliographyItems(items)
    }
    
    private func PubMedIDs(proteinDataBankID PDBID:String) -> [String] {
        return []
    }
    
    private func bibliographyItems(proteinDataID PDBID:String) throws -> [BibliographyItem] {
        let baseURL = self.baseURL()
        guard let components = NSURLComponents(URL: baseURL, resolvingAgainstBaseURL: false) else {
            throw ResolvingError.InvalidResolverURL(baseURL)
        }
        components.query = "structuredId=\(PDBID)"
        guard let queryURL = components.URL else {
            throw ResolvingError.InvalidResolverURLComponents(components)
        }
        
        var response: NSURLResponse?
        let data = try NSURLConnection.sendSynchronousRequest(NSURLRequest(URL: queryURL), returningResponse: &response)
        guard let httpResponse = response as? NSHTTPURLResponse else {
            throw ResolvingError.UnexpectedResponse(response)
        }
        guard httpResponse.statusCode.marksSuccess else {
            throw ResolvingError.UnexpectedStatusCode(httpResponse.statusCode)
        }
        
        return []
    }
}