//
//  PDBClient.swift
//  Extensions
//
//  Created by Matias Piipari on 20/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation
import RegexKitLite
import Freddy
import SWXMLHash

public struct ProteinDataBankIdentifier:Resolvable {
    public let identifier:String
    public let originatingString: String
    
    public init(originatingString: String) throws {
        guard originatingString.isUpper() else {
            throw ResolvingError.notResolvable("\(originatingString) contains lowercase characters and therefore cannot be a PDB ID.")
        }
        
        guard (originatingString as NSString).isMatchedBy(regex: type(of: self).identifierValidationPattern()) else {
            throw ResolvingError.notResolvable("\(originatingString) does not look like a PDB ID.")
        }
        
        self.originatingString = originatingString
        self.identifier = (originatingString as NSString).replacing(occurrencesOfRegex: "PDB\\s{0,1}I{0,1}D{0,1}\\s{0,1}", with: "")
    }
    
    // Some examples of matching strings:
    // PDB 1HIV
    // DB ID 1HIV
    public static func capturingPattern() -> String { return "(PDB\\s{0,1}I{0,1}D{0,1}\\s{0,1}[1-9][A-Za-z0-9]{3})" }
    fileprivate static func identifierValidationPattern() -> String { return "[1-9][A-Za-z0-9]{3}" }
}

public struct ProteinDataBankResolver: URLBasedResolver {
    
    fileprivate let _baseURL:URL
    public func baseURL() -> URL {
        return self._baseURL
    }
    
    public init(baseURL:URL = URL(string:"http://www.rcsb.org/pdb/rest/describePDB")!) {
        self._baseURL = baseURL
    }
    
    public static var identifier = "org.rcsb.pdb"
    
    public let resolvableType:Resolvable.Type = {
        return ProteinDataBankIdentifier.self
    }()
    
    public func resolve(_ identifier: String) throws -> ResolvedResult {
        // you can also get info for PDB IDs given the following kind of DOIs, except the metadata is not same quality as PubMed.
        //let result = try DigitalObjectIdentifierResolver().resolve("10.2210/pdb\(PDBID)/pdb")
        //return result
        
        let PDBID = try ProteinDataBankIdentifier(originatingString:identifier)
        let items = try self.bibliographyItems(proteinDataID: PDBID)
        guard items.count > 0 else {
            return ResolvedResult(resolvable:PDBID, result:.none)
        }
        
        return ResolvedResult(resolvable:PDBID, result:.bibliographyItems(items))
    }
    
    fileprivate func resolvedResult(document doc:XMLIndexer) throws -> ResolvedResult {
        let record = doc["PDBdescription"]["PDB"]
        
        print(record)
        guard let recordElem = record.element else {
            throw ResolvingError.unexpectedResponseObject(record)
        }
        
        guard let PMID = recordElem.allAttributes["pubmedId"] else {
            throw ResolvingError.missingIdentifier(recordElem)
        }
        
        let result = try PubMedResolver().resolve(PMID.text)
        
        return result
    }
    
    fileprivate func bibliographyItems(proteinDataID PDBID:ProteinDataBankIdentifier) throws -> [BibliographyItem] {
        let baseURL = self.baseURL()
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw ResolvingError.invalidResolverURL(baseURL)
        }
        components.query = "structureId=\(PDBID.identifier)"
        guard let queryURL = components.url else {
            throw ResolvingError.invalidResolverURLComponents(components)
        }
        
        let response = try NSURLConnection.sendRateLimitedSynchronousRequest(URLRequest(url: queryURL),
                                                                             rateLimitLabel: self.rateLimitLabel,
                                                                             rateLimit: self.rateLimit)
        
        guard response.statusCode.marksSuccess else {
            throw ResolvingError.unexpectedStatusCode(response.statusCode)
        }
        
        let doc = SWXMLHash.parse(response.data)
        let result = try self.resolvedResult(document: doc)
        
        switch result.result {
        case .bibliographyItems(let items):
            return items
            
        case .none:
            return []
            
        default:
            throw ResolvingError.unexpectedResolvedResponse(result)
        }
    }
}
