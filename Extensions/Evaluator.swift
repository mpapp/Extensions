//
//  Evaluator.swift
//  Extensions
//
//  Created by Matias Piipari on 06/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

public enum EvaluatorError: Int {
    case MissingReturnValue
    case UnexpectedReturnValueType
}

@objc public class Evaluator:NSObject {
    public var identifier:String {
        fatalError("Implement in subclass")
    }
    
    public var fileExtensions:Set<String> {
        fatalError("Implement in subclass")
    }
    
    public func evaluate(input:String, outputHandler:(Bool)->Void, errorHandler:(EvaluatorError, String)->Void) throws {
        fatalError("Implement in subclass")
    }
    
    public func evaluate(input:String, outputHandler:(Int)->Void, errorHandler:(EvaluatorError, String)->Void) throws {
        fatalError("Implement in subclass")
    }
    
    public func evaluate(input:String, outputHandler:(Double)->Void, errorHandler:(EvaluatorError, String)->Void) throws {
        fatalError("Implement in subclass")
    }
    
    public func evaluate(input:String, outputHandler:(String)->Void, errorHandler:(EvaluatorError, String)->Void) throws {
        fatalError("Implement in subclass")
    }
    
    public func evaluate(input:String, outputHandler:(AnyObject)->Void, errorHandler:(EvaluatorError, String)->Void) throws {
        fatalError("Implement in subclass")
    }
    
    public func evaluate(input:String, outputHandler:([AnyObject])->Void, errorHandler:(EvaluatorError, String)->Void) throws {
        fatalError("Implement in subclass")
    }
}