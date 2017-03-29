//
//  Procedure.swift
//  Extensions
//
//  Created by Matias Piipari on 08/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation
import Freddy



public struct ProcessableOption : OptionSet {
    public let rawValue : Int
    
    public init(rawValue:Int) {
        self.rawValue = rawValue
    }
    
    public init(string:String) throws {
        switch string.lowercased() {
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
            throw ProcedureError.unexpectedOption(string)
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
    case stringData(String)
    case intData(Int)
    case doubleData(Double)
    case boolData(Bool)
    case pListEncodableScalar(Any)
    case pListEncodableArray([Any])
    
    public var description: String {
        switch self {
        case .stringData(let str):
            return str
            
        case .doubleData(let d):
            return String(d)
            
        case .intData(let i):
            return String(i)
            
        case .boolData(let b):
            return String(b)
            
        case .pListEncodableArray(let ps):
            return String(describing: ps)
        
        case .pListEncodableScalar(let p):
            return String(describing: p)
        }
    }
}

internal enum ProcedureError:Error {
    case evaluationFailed(EvaluatorError)
    case unexpectedOption(String)
}

open class Procedure:Hashable {
    //internal weak let evaluator:Evaluator?
    let source:String
    
    let inputTypes:ProcessableOption
    let outputTypes:ProcessableOption
    
    let evaluatorID:String
    
    open var hashValue: Int {
        return source.hashValue ^ evaluatorID.hashValue
    }
    
    public required init(evaluatorID:String, source:String, inputTypes:ProcessableOption, outputTypes:ProcessableOption) {
        self.evaluatorID = evaluatorID
        self.source = source
        self.inputTypes = inputTypes
        self.outputTypes = outputTypes
    }
    
    fileprivate static let defaultInputTypes:[String] = ["int", "double", "string"]
    fileprivate static let defaultOutputTypes:[String] = Procedure.defaultInputTypes
    
    public init(json: JSON) throws {
        self.evaluatorID = try json.getString(at: "evaluator")
        
        self.source = try json.getString(at: "source")
        
        let defaultInputTypes = type(of: self).defaultInputTypes.map { JSON($0) }
        let defaultOutputTypes = type(of: self).defaultOutputTypes.map { JSON($0) }
        
        let inputTypeCount = try json.getArray(at: "inputTypes", or: defaultInputTypes).count
        let inputTypeStrings:[String] = try (0..<inputTypeCount).map { return try json.getString(at: "inputTypes", $0) }
        
        let outputTypeCount = try json.getArray(at: "outputTypes", or: defaultOutputTypes).count
        let outputTypeStrings:[String] = try (0..<outputTypeCount).map { return try json.getString(at: "outputTypes", $0) }
        
        self.inputTypes = try ProcessableOption(strings:inputTypeStrings)
        self.outputTypes = try ProcessableOption(strings:outputTypeStrings)
    }
}

public func ==(lhs: Procedure, rhs: Procedure) -> Bool {
    return lhs.source == rhs.source && lhs.inputTypes == rhs.inputTypes && lhs.evaluatorID == rhs.evaluatorID
}
