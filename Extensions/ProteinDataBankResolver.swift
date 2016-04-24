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
        
        guard (identifier as NSString).isMatchedByRegex(self.dynamicType.identifierValidationPattern) else {
            throw ResolvingError.NotResolvable("\(identifier) does not look like a PDB ID.")
        }
        
        self.identifier = identifier
    }
    
    // Some examples of matching strings:
    // PDB 1HIV
    // DB ID 1HIV
    public static let capturingPattern:String = "PDB\\s{0,1}I{0,1}D{0,1}\\s{0,1}([1-9][A-Za-z0-9]{3})"
    public var capturingPattern: String {
        return capturingPattern
    }
    
    private static let identifierValidationPattern:String = "[1-9][A-Za-z0-9]{3}"
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
        // you can also get info for PDB IDs given the following kind of DOIs, except the metadata is not same quality as PubMed.
        //let result = try DigitalObjectIdentifierResolver().resolve("10.2210/pdb\(PDBID)/pdb")
        //return result
        
        let items = try self.bibliographyItems(proteinDataID: ProteinDataBankIdentifier(identifier:identifier))
        guard items.count > 0 else {
            return ResolvedResult.None
        }
        
        return ResolvedResult.BibliographyItems(items)
    }
    
    private func resolvedResult(document doc:XMLIndexer) throws -> ResolvedResult {
        let record = doc["PDBdescription"]["PDB"]
        
        print(record)
        guard let recordElem = record.element else {
            throw ResolvingError.UnexpectedResponseObject(record)
        }
        
        guard let PMID = recordElem.attributes["pubmedId"] else {
            throw ResolvingError.MissingIdentifier(recordElem)
        }
        
        let result = try PubMedResolver().resolve(PMID)
        
        return result
    }
    
    private func bibliographyItems(proteinDataID PDBID:ProteinDataBankIdentifier) throws -> [BibliographyItem] {
        let baseURL = self.baseURL()
        guard let components = NSURLComponents(URL: baseURL, resolvingAgainstBaseURL: false) else {
            throw ResolvingError.InvalidResolverURL(baseURL)
        }
        components.query = "structureId=\(PDBID.identifier)"
        guard let queryURL = components.URL else {
            throw ResolvingError.InvalidResolverURLComponents(components)
        }
        
        let response = try NSURLConnection.sendRateLimitedSynchronousRequest(NSURLRequest(URL: queryURL),
                                                                             rateLimitLabel: self.rateLimitLabel,
                                                                             rateLimit: self.rateLimit)
        
        guard response.statusCode.marksSuccess else {
            throw ResolvingError.UnexpectedStatusCode(response.statusCode)
        }
        
        let doc = SWXMLHash.parse(response.data)
        let result = try self.resolvedResult(document: doc)
        
        switch result {
        case .BibliographyItems(let items):
            return items
            
        case .None:
            return []
            
        default:
            throw ResolvingError.UnexpectedResolvedResponse(result)
        }
    }
}