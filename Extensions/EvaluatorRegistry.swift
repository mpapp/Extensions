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

internal class EvaluatorRegistry {
    
    static let sharedInstance:EvaluatorRegistry = EvaluatorRegistry()

    private init() {
    }
    
    lazy var evaluators:[String:Evaluator] = {
        
        var es:[Evaluator?] = [JavaScriptEvaluatorJSC(),
                               REvaluator()]
        
        do {
            es.append(try JavaScriptEvaluatorWebKit(webView:nil))
        }
        catch {
            print("Error occurred when attempting to initialize a JavaScript evaluator: \(error)")
        }
        
        var evals = [String:Evaluator]()
    
        for eval in es {
            if let eval = eval {
                evals[eval.identifier] = eval
            }
        }
        
        return evals
    }()
    
    internal func createEvaluator(procedure procedure:Procedure, containingExtension:Extension) throws -> Evaluator {
        return try self.createEvaluator(identifier:procedure.evaluatorID, containingExtension: containingExtension)
    }
    
    internal func createEvaluator(identifier identifier:String, containingExtension:Extension) throws -> Evaluator {
        guard var e = self.evaluators[identifier] else {
            throw EvaluatorRegistryErrorCode.NoSuchEvaluator("No evaluator with identifier \(identifier)")
        }
        
        e = try e.dynamicType.init(evaluator:e, containingExtension:containingExtension)
        
        return e
    }
}