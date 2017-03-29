//
//  LaTeXMathResolver.swift
//  Extensions
//
//  Created by Matias Piipari on 24/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation
import SWXMLHash

public struct InlineLaTeXFragment:Resolvable {
    public let identifier:String
    public let originatingString: String
    
    public init(originatingString: String) throws {
        guard (originatingString as NSString).isMatched(byRegex: type(of: self).capturingPattern()) else {
            throw ResolvingError.notResolvable("\(originatingString) does not look like a PDB ID.")
        }
        
        self.originatingString = originatingString
        self.identifier = (originatingString as NSString).captureComponentsMatched(byRegex: type(of: self).contentCapturingPattern())[1] as! String
    }
    
    public static func capturingPattern() -> String { return "(\\b\\$.+\\$\\b)" }
    fileprivate static func contentCapturingPattern() -> String { return "\\b(\\$.+\\$)\\b" }
}

public struct LaTeXMathResolver:Resolver {
    
    fileprivate let _baseURL:URL
    public func baseURL() -> URL {
        return self._baseURL
    }
    
    public init(baseURL:URL = URL(string:"http://www.rcsb.org/pdb/rest/describePDB")!) {
        self._baseURL = baseURL
    }
    
    public static let identifier = "org.latex-project.math"
    
    public let resolvableType:Resolvable.Type = {
        return ProteinDataBankIdentifier.self
    }()
    
    public func resolve(_ string: String) throws -> ResolvedResult {
        // you can also get info for PDB IDs given the following kind of DOIs, except the metadata is not same quality as PubMed.
        //let result = try DigitalObjectIdentifierResolver().resolve("10.2210/pdb\(PDBID)/pdb")
        //return result
        
        let PDBID = try ProteinDataBankIdentifier(originatingString:string)
        let items = try self.bibliographyItems(proteinDataID: PDBID)
        guard items.count > 0 else {
            return ResolvedResult(resolvable:PDBID, result: .none)
        }
        
        return ResolvedResult(resolvable:PDBID, result:.bibliographyItems(items))
    }
    
    fileprivate func resolvedResult(document doc:XMLIndexer) throws -> ResolvedResult {
        let record = doc["PDBdescription"]["PDB"]
        
        print(record)
        guard let recordElem = record.element else {
            throw ResolvingError.unexpectedResponseObject(record)
        }
        
        guard let PMIDAttrib = recordElem.allAttributes["pubmedId"] else {
            throw ResolvingError.missingIdentifier(record)
        }
        
        let result = try PubMedResolver().resolve(PMIDAttrib.text)
        
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
