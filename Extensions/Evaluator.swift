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
    
    static func encode(processable:Processable?) -> AnyObject?
    
    func evaluate(source:String,
                  input:Processable?,
                  outputHandler:(Processable?) -> Void,
                  errorHandler:(EvaluatorError, String) -> Void)
}
