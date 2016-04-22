//
//  PubMedClient.swift
//  Extensions
//
//  Created by Matias Piipari on 20/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

public class PubMedResolver: Resolver {
    
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
    
    public func resolve(resolvable: Resolvable) -> ResolvableResult {
        self
        
        guard let bibItems = self.bibliographyItem(resolvable.identifier) else {
            return ResolvableResult.None
        }
        
        return ResolvableResult.BibliographyItems(bibItems as! [AnyObject])
    }
    
}