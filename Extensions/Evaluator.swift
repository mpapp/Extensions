//
//  Evaluator.swift
//  Extensions
//
//  Created by Matias Piipari on 06/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

internal enum EvaluatorError: ErrorType {
    case MissingReturnValue
    case UnexpectedReturnValueType
    case MissingExports(Extension?, Evaluator)
    case MissingProcessFunction(Extension?, Evaluator)
    case EvaluationFailed(Extension?, Evaluator, AnyObject?)
    case UnexpectedNilInput(Extension?, Evaluator)
}

// needs to conform to NSObjectProtocol such that when this type is used as a property type, one can use NSClassFromString 
// (non-Objective Swift classes do not have reflection of this sort at the moment)
internal protocol Evaluator {
    
    var identifier:String { get }
    var fileExtensions:Set<String> { get }
    
    static func encode(processable:Processable?) -> AnyObject?
    static func decode(processable:AnyObject?) -> Processable?
    
    init(evaluator:Evaluator, containingExtension:Extension) throws
    
    func evaluate(source:String,
                  input:Processable?,
                  outputHandler:(Processable?) -> Void,
                  errorHandler:(EvaluatorError) -> Void)
}

public protocol ExtensionContained {
    weak var containingExtension:Extension? { get set }
}

internal protocol ExtensionContainedEvaluator:Evaluator, ExtensionContained { }
