//
//  PDBClient.swift
//  Extensions
//
//  Created by Matias Piipari on 20/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

public struct ProteinDataBankIdentifier:Resolvable {
    private let identifierString:String
    
    public func identifier() -> String {
        return self.identifierString
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
    
    public func resolve(resolvable: Resolvable) -> ResolvableResult {
        return ResolvableResult.BibliographyItem(self.bibliographyItems(proteinDataID: resolvable.identifier()))
    }
    
    private func PubMedIDs(proteinDataBankID PDBID:String) -> [String] {
        return []
    }
    
    private func bibliographyItems(proteinDataID PDBID:String) -> [BibliographyItem] {
        return []
    }
}