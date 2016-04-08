//
//  Extension.swift
//  Extensions
//
//  Created by Matias Piipari on 06/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

protocol ExtensionLike {
    var identifier:String { get }
    var procedures:[Procedure] { get }
}

enum ExtensionError:ErrorType {
    case MissingEvaluatorKey
    case InvalidEvaluatorClass(String)
    case InvalidEvaluatorType(AnyClass?)
    case NotPropertyList([String:AnyObject])
}

@objc public class Extension: NSObject, ExtensionLike {
    let identifier:String
    let procedures:[Procedure]
    
    init(identifier:String, procedures:[Procedure]) {
        self.identifier = identifier
        self.procedures = procedures
        super.init()
    }
}