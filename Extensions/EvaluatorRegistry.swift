//
//  EvaluatorRegistry.swift
//  Extensions
//
//  Created by Matias Piipari on 06/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

public enum EvaluatorRegistryErrorCode: ErrorType {
    case NoSuchEvaluator(String)
}

public class EvaluatorRegistry {
    
    public static let sharedInstance:EvaluatorRegistry = EvaluatorRegistry()

    private init() {
    }
    
    lazy public var evaluators:[String:Evaluator] = {
        let es = [JavaScriptEvaluatorWebKit(),
                  JavaScriptEvaluatorJSC(),
                  REvaluator()]
        
        var evals = [String:Evaluator]()
    
        for eval in es {
            //evals[eval.identifier] = eval
        }
        
        return evals
    }()
    
    public func evaluator(identifier identifier:String) throws -> Evaluator {
        guard let evaluator = self.evaluators[identifier] else {
            throw EvaluatorRegistryErrorCode.NoSuchEvaluator("No evaluator with identifier \(identifier)")
        }
        
        return evaluator
    }
}