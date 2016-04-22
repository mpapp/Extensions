//
//  PubMedClient.swift
//  Extensions
//
//  Created by Matias Piipari on 20/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation
import RegexKitLite

public struct PubMedIdentifier: Resolvable {
    public let identifier: String
    public init(identifier: String) throws {
        let lowercaseID = identifier.lowercaseString
        
        let evaluatedID:String
        if lowercaseID.hasPrefix("pmid:") {
            evaluatedID = lowercaseID.stringByReplacingOccurrencesOfRegex("^pmid:", withString: "")
        }
        else {
            evaluatedID = lowercaseID
        }
        
        guard (evaluatedID as NSString).isMatchedByRegex("^\\d{1,20}$") else {
            throw ResolvingError.NotResolvable(evaluatedID)
        }
        
        self.identifier = evaluatedID
    }
}

public class PubMedResolver: Resolver {
    
    public let resolvableType: Resolvable.Type = {
        return PubMedIdentifier.self
    }()
    
    private let _baseURL:NSURL
    
    
    public func baseURL() -> NSURL {
        return _baseURL
    }
    
    public init(baseURL:NSURL = NSURL(string: "http://entrez…")!) {
        self._baseURL = baseURL
    }
    
    private func bibliographyItem(PMID:String) -> BibliographyItem? {
        return nil
    }
    
    public func resolve(identifier: String) -> ResolvableResult {
        guard let bibItem = self.bibliographyItem(identifier) else {
            return ResolvableResult.None
        }
        
        return ResolvableResult.BibliographyItems([bibItem])
    }
    
}