//
//  NSFileManager+Extensions.swift
//  Extensions
//
//  Created by Matias Piipari on 10/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

extension FileManager {

    func enumerate(rootDirectoryURL rootURL: URL, fileHandler:(_ URL:URL)->Void) throws {
        let rootPath = rootURL.path
        
        let subs = try FileManager.default.subpathsOfDirectory(atPath: rootPath)
        for sub in subs {
            fileHandler(rootURL.appendingPathComponent(sub))
        }
    }
    
}
