//
//  NSFileManager+Extensions.swift
//  Extensions
//
//  Created by Matias Piipari on 10/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//
//  ---------------------------------------------------------------------------
//
//  © 2019 Atypon Systems LLC
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

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
