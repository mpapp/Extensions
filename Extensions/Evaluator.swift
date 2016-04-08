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

// needs to conform to NSObjectProtocol such that when this type is used as a property type, one can use NSClassFromString 
// (non-Objective Swift classes do not have reflection of this sort at the moment)
public protocol Evaluator:NSObjectProtocol {
    var identifier:String { get }
    
    var fileExtensions:Set<String> { get }
    
    func evaluate(input:String, outputHandler:(NSNumber) -> Void, errorHandler: (EvaluatorError, String) -> Void) throws
    func evaluate(input:String, outputHandler:(Bool)->Void, errorHandler:(EvaluatorError, String)->Void) throws
    func evaluate(input:String, outputHandler:(Int)->Void, errorHandler:(EvaluatorError, String)->Void) throws
    func evaluate(input:String, outputHandler:(Double)->Void, errorHandler:(EvaluatorError, String)->Void) throws
    
    func evaluate(input:String, outputHandler:(AnyObject)->Void, errorHandler:(EvaluatorError, String)->Void) throws
    func evaluate(input:String, outputHandler:(String)->Void, errorHandler:(EvaluatorError, String)->Void) throws
    func evaluate(input:String, outputHandler:([AnyObject])->Void, errorHandler:(EvaluatorError, String)->Void) throws
}

extension Evaluator {
    
    // A helper for NSNumber based evaluation
    public func evaluate(input: String, outputHandler: (NSNumber) -> Void, errorHandler: (EvaluatorError, String) -> Void) throws {
        try evaluate(input, outputHandler: { (output:AnyObject) in
            guard let outputNumber = output as? NSNumber else {
                errorHandler(EvaluatorError.UnexpectedReturnValueType, "Return value is of unexpected type: \(output.dynamicType) (expecting NSNumber)")
                return
            }
            
            outputHandler(outputNumber)
            
            }, errorHandler: errorHandler)
    }
    
    public func evaluate(input: String, outputHandler: (Bool) -> Void, errorHandler: (EvaluatorError, String) -> Void) throws {
        try evaluate(input, outputHandler: { (output:NSNumber) in
            outputHandler(output.boolValue)
            }, errorHandler: errorHandler)
    }
    
    public func evaluate(input: String, outputHandler: (Int) -> Void, errorHandler: (EvaluatorError, String) -> Void) throws {
        try evaluate(input, outputHandler: { (output:NSNumber) in
            outputHandler(Int(output.intValue))
            }, errorHandler: errorHandler)
    }
    
    public func evaluate(input: String, outputHandler: (Double) -> Void, errorHandler: (EvaluatorError, String) -> Void) throws {
        try evaluate(input, outputHandler: { (output:NSNumber) in
            outputHandler(Double(output.doubleValue))
            }, errorHandler: errorHandler)
    }
    
    public func evaluate(input: String, outputHandler: (String) -> Void, errorHandler: (EvaluatorError, String) -> Void) throws {
        try evaluate(input, outputHandler: { (output:AnyObject) in
            guard let outputString = output as? String else {
                errorHandler(EvaluatorError.UnexpectedReturnValueType, "Return value is of unexpected type: \(output.dynamicType) (expecting String)")
                return
            }
            
            outputHandler(outputString)
            }, errorHandler: errorHandler)
    }
    
    public func evaluate(input: String, outputHandler: ([AnyObject]) -> Void, errorHandler: (EvaluatorError, String) -> Void) throws {
        try evaluate(input, outputHandler: { (output:AnyObject) in
            guard let outputArray = output as? [AnyObject] else {
                errorHandler(EvaluatorError.UnexpectedReturnValueType, "Return value is of unexpected type: \(output.dynamicType) (expecting String)")
                return
            }
            
            outputHandler(outputArray)
            }, errorHandler: errorHandler)
    }
}