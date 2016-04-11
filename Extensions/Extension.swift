//
//  Extension.swift
//  Extensions
//
//  Created by Matias Piipari on 06/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation
import Freddy

protocol ExtensionLike {
    var identifier:String { get }
    var procedures:[Procedure] { get }
}

public enum ExtensionError:ErrorType {
    case MissingEvaluatorKey
    case InvalidEvaluatorClass(String)
    case InvalidEvaluatorType(AnyClass?)
    case NotPropertyList([String:AnyObject])
    case MissingInfoDictionary(NSBundle)
    case InvalidExtensionAtURL(NSURL)
    case ExtensionFailedToLoad(NSBundle)
    case UnderlyingError(ErrorType)
}

@objc public class Extension: NSObject, ExtensionLike {
    public let identifier:String
    public let procedures:[Procedure]
    
    init(identifier:String, procedures:[Procedure]) {
        self.identifier = identifier
        self.procedures = procedures
        super.init()
    }
}