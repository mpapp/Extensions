//
//  ExtensionRegistry.swift
//  Extensions
//
//  Created by Matias Piipari on 08/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

public enum ExtensionRegistryErrorCode: ErrorType {
    case NoSuchExension(String)
}

public class ExtensionRegistry {
    
    public static let sharedInstance:ExtensionRegistry = ExtensionRegistry()
    private(set) public var extensions:[String:Extension] = [:]
    
    public var extensionSet:Set<Extension> {
        return Set(self.extensions.values)
    }
    
    private init() {
    }
    
    private class func loadExtensionBundles(rootURL:NSURL, loadFailureHandler:((URL:NSURL, error:ExtensionError)->Void)? = nil) throws -> [Extension] {
        
        var exts:[Extension] = []
        
        try NSFileManager.defaultManager().enumerate(rootDirectoryURL: rootURL) { (URL:NSURL) in
            if URL.pathExtension == "extension" {
                if let bundle = NSBundle(URL: URL) {
                    if !bundle.load() {
                        if let loadFailureHandler = loadFailureHandler {
                            loadFailureHandler(URL:URL, error:ExtensionError.ExtensionFailedToLoad(bundle))
                        }
                    }
                    else {
                        do {
                            let ext = try Extension.fromBundle(bundle)
                            exts.append(ext)
                        }
                        catch {
                            if let error = error as? ExtensionError, let loadFailureHandler = loadFailureHandler {
                                loadFailureHandler(URL:URL, error:error)
                            }
                            else if let loadFailureHandler = loadFailureHandler {
                                loadFailureHandler(URL: URL, error: ExtensionError.UnderlyingError(error))
                            }
                        }
                    }
                }
                else {
                    if let loadFailureHandler = loadFailureHandler {
                        loadFailureHandler(URL:URL, error:ExtensionError.InvalidExtensionAtURL(URL))
                    }
                }
            }
        }
        
        return exts
    }
    
    // You are required to call loadExtensions before attempting to access extensions with extensionWithIdentifier.
    public func loadExtensions(rootURL:NSURL? = nil, replaceExisting:Bool = true, loadFailureHandler:((URL:NSURL, error:ExtensionError)->Void)? = nil) throws {
        
        let root:NSURL
        if let rootURL = rootURL {
            root = rootURL
        }
        else {
            root = NSBundle.mainBundle().bundleURL
        }
        
        let extensions = try self.dynamicType.loadExtensionBundles(root, loadFailureHandler:loadFailureHandler)
        
        var extensionsDict = [String:Extension]()
        for ext in extensions {
            guard let existingExtension = self.extensions[ext.identifier] where replaceExisting else {
                extensionsDict[ext.identifier] = ext
                continue
            }
            extensionsDict[ext.identifier] = existingExtension
        }

        self.extensions = extensionsDict
    }
    
    // extension is a reserved word, so can't use it as a method name…
    public func extensionWithIdentifier(identifier:String) throws -> Extension {
        guard let ext = self.extensions[identifier] else {
            throw EvaluatorRegistryErrorCode.NoSuchEvaluator("No extension with identifier \(identifier)")
        }
        
        return ext
    }
}