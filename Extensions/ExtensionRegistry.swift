//
//  ExtensionRegistry.swift
//  Extensions
//
//  Created by Matias Piipari on 08/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

public enum ExtensionRegistryErrorCode: Error {
    case noSuchExension(String)
}

public final class ExtensionRegistry {
    
    public static let sharedInstance:ExtensionRegistry = ExtensionRegistry()
    fileprivate init() { } // don't even try to instantiate one…
    
    fileprivate(set) public var extensions:[String:Extension] = [:]
    
    public var extensionSet:Set<Extension> {
        return Set(self.extensions.values)
    }
    
    // You are required to call loadExtensions before attempting to access extensions with extensionWithIdentifier.
    public func loadExtensions(_ rootURL:URL? = nil, replaceExisting:Bool = true, loadFailureHandler:((_ URL:URL, _ error:ExtensionError)->Void)? = nil) throws {
        
        let root:URL
        if let rootURL = rootURL {
            root = rootURL
        }
        else {
            root = Bundle.main.bundleURL
        }
        
        let extensions = try type(of: self).loadExtensionBundles(root, loadFailureHandler:loadFailureHandler)
        
        var extensionsDict = [String:Extension]()
        for ext in extensions {
            guard let existingExtension = self.extensions[ext.identifier], replaceExisting else {
                extensionsDict[ext.identifier] = ext
                continue
            }
            extensionsDict[ext.identifier] = existingExtension
        }
        
        self.extensions = extensionsDict
    }
    
    // extension is a reserved word, so can't use it as a method name…
    public func extensionWithIdentifier(_ identifier:String) throws -> Extension {
        guard let ext = self.extensions[identifier] else {
            throw EvaluatorRegistryErrorCode.noSuchEvaluator("No extension with identifier \(identifier)")
        }
        
        return ext
    }
    
    fileprivate class func loadExtensionBundles(_ rootURL:URL, loadFailureHandler:((_ URL:URL, _ error:ExtensionError)->Void)? = nil) throws -> [Extension] {
        
        var exts:[Extension] = []
        
        try FileManager.default.enumerate(rootDirectoryURL: rootURL) { (URL:Foundation.URL) in
            if URL.pathExtension == "extension" {
                if let bundle = Bundle(url: URL) {
                    if !bundle.load() {
                        if let loadFailureHandler = loadFailureHandler {
                            loadFailureHandler(URL, ExtensionError.extensionFailedToLoad(bundle))
                        }
                    }
                    else {
                        do {
                            let ext = try Extension.fromBundle(bundle)
                            exts.append(ext)
                        }
                        catch {
                            if let error = error as? ExtensionError, let loadFailureHandler = loadFailureHandler {
                                loadFailureHandler(URL, error)
                            }
                            else if let loadFailureHandler = loadFailureHandler {
                                loadFailureHandler(URL, ExtensionError.underlyingError(error))
                            }
                        }
                    }
                }
                else {
                    if let loadFailureHandler = loadFailureHandler {
                        loadFailureHandler(URL, ExtensionError.invalidExtensionAtURL(URL))
                    }
                }
            }
        }
        
        return exts
    }
}
