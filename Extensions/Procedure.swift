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
        
        case "bool":
            self.rawValue = ProcessableOption.BoolOption.rawValue
                        
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
    static let BoolOption = ProcessableOption(rawValue:2)
    static let DoubleOption = ProcessableOption(rawValue:4)
    static let StringOption = ProcessableOption(rawValue:8)
    static let PListEncodableScalarOption = ProcessableOption(rawValue:16)
    static let PListEncodableArrayOption = ProcessableOption(rawValue:32)
    
    static let DefaultOptions = ProcessableOption.DoubleOption.union(.IntOption).union(.StringOption)
}

public enum Processable:CustomStringConvertible {
    case StringData(String)
    case IntData(Int)
    case DoubleData(Double)
    case BoolData(Bool)
    case PListEncodableScalar(AnyObject)
    case PListEncodableArray([AnyObject])
    
    public var description: String {
        switch self {
        case .StringData(let str):
            return str
            
        case .DoubleData(let d):
            return String(d)
            
        case .IntData(let i):
            return String(i)
            
        case .BoolData(let b):
            return String(b)
            
        case .PListEncodableArray(let ps):
            return String(ps)
        
        case .PListEncodableScalar(let p):
            return String(p)
        }
    }
}

public enum ProcedureError:ErrorType {
    case EvaluationFailed(EvaluatorError, String)
    case UnexpectedOption(String)
}

public class Procedure {
    //internal weak let evaluator:Evaluator?
    internal let source:String
    
    internal let inputTypes:ProcessableOption
    internal let outputTypes:ProcessableOption
    
    internal let evaluatorID:String
    
    required public init(evaluatorID:String, source:String, inputTypes:ProcessableOption, outputTypes:ProcessableOption) {
        self.evaluatorID = evaluatorID
        self.source = source
        self.inputTypes = inputTypes
        self.outputTypes = outputTypes
    }
    
    private static let defaultInputTypes:[String] = ["int", "double", "string"]
    private static let defaultOutputTypes:[String] = Procedure.defaultInputTypes
    
    public init(json: JSON) throws {
        self.evaluatorID = try json.string("evaluator")
        
        self.source = try json.string("source")
        
        let defaultInputTypes = self.dynamicType.defaultInputTypes.map { JSON($0) }
        let defaultOutputTypes = self.dynamicType.defaultOutputTypes.map { JSON($0) }
        
        let inputTypeCount = try json.array("inputTypes", or: defaultInputTypes).count
        let inputTypeStrings:[String] = try (0..<inputTypeCount).map { return try json.string("inputTypes", $0) }
        
        let outputTypeCount = try json.array("outputTypes", or: defaultOutputTypes).count
        let outputTypeStrings:[String] = try (0..<outputTypeCount).map { return try json.string("outputTypes", $0) }
        
        self.inputTypes = try ProcessableOption(strings:inputTypeStrings)
        self.outputTypes = try ProcessableOption(strings:outputTypeStrings)
    }
}