//
//  Procedure.swift
//  Extensions
//
//  Created by Matias Piipari on 08/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation
import Freddy



public struct ProcessableOption : OptionSetType {
    public let rawValue : Int
    
    public init(rawValue:Int) {
        self.rawValue = rawValue
    }
    
    public init(string:String) throws {
        switch string.lowercaseString {
        case "int":
            self.rawValue = ProcessableOption.IntOption.rawValue
        
        case "double":
            self.rawValue = ProcessableOption.DoubleOption.rawValue
        
        case "string":
            self.rawValue = ProcessableOption.StringOption.rawValue
        
        case "scalar":
            self.rawValue = ProcessableOption.PListEncodableScalarOption.rawValue
        
        case "array":
            self.rawValue = ProcessableOption.PListEncodableArrayOption.rawValue
        
        default:
            throw ProcedureError.UnexpectedOption(string)
        }
    }
    
    public init(strings:[String]) throws {
        var opts = ProcessableOption.NoneOption
        for s in strings {
            opts = opts.union(try ProcessableOption(string:s))
        }
        
        self.rawValue = opts.rawValue
    }
    
    static let NoneOption = ProcessableOption(rawValue:0)
    static let IntOption = ProcessableOption(rawValue:1)
    static let DoubleOption = ProcessableOption(rawValue:2)
    static let StringOption = ProcessableOption(rawValue:4)
    static let PListEncodableScalarOption = ProcessableOption(rawValue:8)
    static let PListEncodableArrayOption = ProcessableOption(rawValue:16)
    
    static let DefaultOptions = ProcessableOption.DoubleOption.union(.IntOption).union(.StringOption)
}

public enum Processable {
    case StringData(String)
    case IntData(Int)
    case DoubleData(Double)
    case PListEncodableScalar(AnyObject)
    case PListEncodableArray([AnyObject])
}

public enum ProcedureError:ErrorType {
    case EvaluationFailed(EvaluatorError, String)
    case UnexpectedOption(String)
}

public class Procedure {
    let evaluator:Evaluator
    let source:String
    
    let inputTypes:ProcessableOption
    let outputTypes:ProcessableOption
    
    required public init(evaluator:Evaluator, source:String, inputTypes:ProcessableOption, outputTypes:ProcessableOption) {
        self.evaluator = evaluator
        self.source = source
        self.inputTypes = inputTypes
        self.outputTypes = outputTypes
    }
    
    private static let defaultInputTypes:[String] = ["int", "double", "string"]
    private static let defaultOutputTypes:[String] = Procedure.defaultInputTypes
    
    public init(json: JSON) throws {
        let evaluatorID = try json.string("evaluator")
        let evaluator = try EvaluatorRegistry.sharedInstance.evaluator(identifier: evaluatorID)
        self.evaluator = evaluator
        self.source = try json.string("source")
        
        let defaultInputTypes = self.dynamicType.defaultInputTypes.map { JSON($0) }
        let defaultOutputTypes = self.dynamicType.defaultOutputTypes.map { JSON($0) }
        
        let inputTypeCount = try json.array("inputTypes", or: defaultInputTypes).count
        let inputTypeStrings:[String] = try (0..<inputTypeCount).map { return try json.string("inputTypes", $0) }
        
        let outputTypeCount = try json.array("outputTypes", or: defaultOutputTypes).count
        let outputTypeStrings:[String] = try (0..<outputTypeCount).map { return try json.string("inputTypes", $0) }
        
        self.inputTypes = try ProcessableOption(strings:inputTypeStrings)
        self.outputTypes = try ProcessableOption(strings:outputTypeStrings)
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