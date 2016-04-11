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
    case ExtensionHasNoProcedures(Extension)
}

@objc public class Extension: NSObject, ExtensionLike {
    public let identifier:String
    public let procedures:[Procedure]
    
    internal init(identifier:String, procedures:[Procedure]) {
        self.identifier = identifier
        self.procedures = procedures
        super.init()
    }
    
    public func evaluate(input:Processable, procedureHandler:(input:Processable) -> Processable, errorHandler:(error:ErrorType)->Void) throws {
    
        if self.procedures.count == 0 {
            throw ExtensionError.ExtensionHasNoProcedures(self)
        }
        
        /*
        switch input {
        case .DoubleData(let d):
            
            
        default:
            
        }
        
        self.procedures.first?.evaluator.evaluate(<#T##input: String##String#>, outputHandler: <#T##([AnyObject]) -> Void#>, errorHandler: <#T##(EvaluatorError, String) -> Void#>)
        
        for (_, procedure) in self.procedures.enumerate() {
        
        }
        */
    }
}