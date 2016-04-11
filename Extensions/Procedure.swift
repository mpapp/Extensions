//
//  Procedure.swift
//  Extensions
//
//  Created by Matias Piipari on 08/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation
import Freddy

public enum Processable {
    case StringData(String)
    case IntData(Int)
    case DoubleData(Double)
    case PListEncodableScalar(AnyObject)
    case PListEncodableArray([AnyObject])
}

public enum ProcedureError:ErrorType {
    case EvaluationFailed(EvaluatorError, String)
}

public class Procedure {
    let evaluator:Evaluator
    let source:String
    
    required public init(evaluator:Evaluator, source:String) {
        self.evaluator = evaluator
        self.source = source
        //self.resources = resources
    }
    
    public init(json: JSON) throws {
        let evaluatorID = try json.string("evaluator")
        let evaluator = try EvaluatorRegistry.sharedInstance.evaluator(identifier: evaluatorID)
        self.evaluator = evaluator
        
        self.source = try json.string("source")
        //self.resources = Set(try json.array("resources").map {
        //    let path = try $0.string()
        //    return NSURL(fileURLWithPath:path)
        //    })
    }
    
    
    public func evaluate(input:Processable, outputHandler:(output:Processable)->Void, errorHandler:(error:ErrorType)->Void) {
        
        /*
        switch input {
        case .DoubleData(let d):
            self.evaluator.evaluate(self.source,
                                    outputHandler: { outputHandler(output:Processable.DoubleData($0)) },
                                    errorHandler: { errorHandler(error:ProcedureError.EvaluationFailed($0, $1)) })
            
        default:
            
        }
        */
    }
}