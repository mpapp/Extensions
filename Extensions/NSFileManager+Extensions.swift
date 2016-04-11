//
//  NSFileManager+Extensions.swift
//  Extensions
//
//  Created by Matias Piipari on 10/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

extension NSFileManager {

    func enumerate(rootDirectoryURL rootURL: NSURL, fileHandler:(URL:NSURL)->Void) throws {
        guard let rootPath = rootURL.path else {
            preconditionFailure("Invalid root URL: \(rootURL)")
        }
        
        let subs = try NSFileManager.defaultManager().subpathsOfDirectoryAtPath(rootPath)
        for sub in subs {
            fileHandler(URL: rootURL.URLByAppendingPathComponent(sub))
        }
    }
    
}