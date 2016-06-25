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
        guard (originatingString as NSString).isMatchedByRegex(self.dynamicType.capturingPattern()) else {
            throw ResolvingError.NotResolvable("\(originatingString) does not look like a PDB ID.")
        }
        
        self.originatingString = originatingString
        self.identifier = (originatingString as NSString).captureComponentsMatchedByRegex(self.dynamicType.contentCapturingPattern())[1] as! String
    }
    
    public static func capturingPattern() -> String { return "(\\b\\$.+\\$\\b)" }
    private static func contentCapturingPattern() -> String { return "\\b(\\$.+\\$)\\b" }
}

public struct LaTeXMathResolver:Resolver {
    
    private let _baseURL:NSURL
    public func baseURL() -> NSURL {
        return self._baseURL
    }
    
    public init(baseURL:NSURL = NSURL(string:"http://www.rcsb.org/pdb/rest/describePDB")!) {
        self._baseURL = baseURL
    }
    
    public static let identifier = "org.latex-project.math"
    
    public let resolvableType:Resolvable.Type = {
        return ProteinDataBankIdentifier.self
    }()
    
    public func resolve(string: String) throws -> ResolvedResult {
        // you can also get info for PDB IDs given the following kind of DOIs, except the metadata is not same quality as PubMed.
        //let result = try DigitalObjectIdentifierResolver().resolve("10.2210/pdb\(PDBID)/pdb")
        //return result
        
        let PDBID = try ProteinDataBankIdentifier(originatingString:string)
        let items = try self.bibliographyItems(proteinDataID: PDBID)
        guard items.count > 0 else {
            return ResolvedResult(resolvable:PDBID, result: .None)
        }
        
        return ResolvedResult(resolvable:PDBID, result:.BibliographyItems(items))
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
        
        switch result.result {
        case .BibliographyItems(let items):
            return items
            
        case .None:
            return []
            
        default:
            throw ResolvingError.UnexpectedResolvedResponse(result)
        }
    }
}
