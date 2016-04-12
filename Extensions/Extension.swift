//
//  Extension.swift
//  Extensions
//
//  Created by Matias Piipari on 06/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation
import Freddy

protocol ExtensionLike {
    var identifier:String { get }
    var procedures:[Procedure] { get }
}

public enum ExtensionError:ErrorType {
    case MissingEvaluatorKey
    case InvalidEvaluatorClass(String)
    case InvalidEvaluatorType(AnyClass?)
    case NotPropertyList([String:AnyObject])
    case MissingInfoDictionary(NSBundle)
    case InvalidExtensionAtURL(NSURL)
    case ExtensionFailedToLoad(NSBundle)
    case UnderlyingError(ErrorType)
    case ExtensionHasNoProcedures(Extension)
}

private class ExtensionState {
    private var procedures:[Procedure]
    private var processable:Processable
    private var lastError:ErrorType?
    private let procedureHandler:(input:Processable, output:Processable) -> Void
    
    private init(procedures:[Procedure], processable:Processable, procedureHandler:(input:Processable, output:Processable) -> Void) {
        self.procedures = procedures
        self.processable = processable
        self.procedureHandler = procedureHandler
    }
}

@objc public class Extension: NSObject, ExtensionLike {
    public let identifier:String
    public let procedures:[Procedure]
    
    internal init(identifier:String, procedures:[Procedure]) {
        self.identifier = identifier
        self.procedures = procedures
        super.init()
    }
    
    public func evaluate(input:Processable, procedureHandler:(input:Processable, output:Processable) -> Void, errorHandler:(error:ErrorType)->Void) throws {
        let state = ExtensionState(procedures:self.procedures, processable: input, procedureHandler: procedureHandler)
        
        if self.procedures.count == 0 {
            throw ExtensionError.ExtensionHasNoProcedures(self)
        }
        
        let procedure = state.procedures.removeFirst()
        procedure.evaluate(input, outputHandler:self.outputHandler(state), errorHandler: self.errorHandler(state))
    }
    
    private func outputHandler(state:ExtensionState) -> (output: Processable) -> Void {
        return {
            let input = state.processable
            let output = $0
            
            state.procedureHandler(input: input, output: output)
            
            // replace input with output
            state.processable = output
            
            if state.procedures.count > 0 {
                let procedure = state.procedures.removeFirst()
                procedure.evaluate(state.processable, outputHandler: self.outputHandler(state), errorHandler: self.errorHandler(state))
            }
        }
    }
    
    private func errorHandler(state:ExtensionState) -> (error:ErrorType) -> Void {
        return {
            state.lastError = $0
        }
    }
}