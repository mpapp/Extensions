//
//  PDBClient.swift
//  Extensions
//
//  Created by Matias Piipari on 20/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation
import RegexKitLite


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
    
    public init(baseURL:NSURL = NSURL(string:"http://…")!) {
        self._baseURL = baseURL
    }
    
    public let resolvableType:Resolvable.Type = {
        return ProteinDataBankIdentifier.self
    }()
    
    public func resolve(identifier: String) -> ResolvableResult {
        let items = self.bibliographyItems(proteinDataID: identifier)
        guard items.count > 0 else {
            return ResolvableResult.None
        }
        
        return ResolvableResult.BibliographyItems(items)
    }
    
    private func PubMedIDs(proteinDataBankID PDBID:String) -> [String] {
        return []
    }
    
    private func bibliographyItems(proteinDataID PDBID:String) -> [BibliographyItem] {
        return []
    }
}