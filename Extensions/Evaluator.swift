//
//  Evaluator.swift
//  Extensions
//
//  Created by Matias Piipari on 06/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

internal enum EvaluatorError: Error {
    case missingReturnValue
    case unexpectedReturnValueType
    case missingExports(Extension?, Evaluator)
    case missingProcessFunction(Extension?, Evaluator)
    case evaluationFailed(Extension?, Evaluator, Any?)
    case unexpectedNilInput(Extension?, Evaluator)
}

// needs to conform to NSObjectProtocol such that when this type is used as a property type, one can use NSClassFromString 
// (non-Objective Swift classes do not have reflection of this sort at the moment)
internal protocol Evaluator {
    
    var identifier:String { get }
    var fileExtensions:Set<String> { get }
    
    static func encode(_ processable:Processable?) -> Any?
    static func decode(_ processable:Any?) -> Processable?
    
    init(evaluator:Evaluator, containingExtension:Extension) throws
    
    func evaluate(_ source:String,
                  input:Processable?,
                  outputHandler:@escaping (Processable?) -> Void,
                  errorHandler:@escaping (EvaluatorError) -> Void)
}

public protocol ExtensionContained {
    var containingExtension:Extension? { get set }
}

internal protocol ExtensionContainedEvaluator:Evaluator, ExtensionContained { }
