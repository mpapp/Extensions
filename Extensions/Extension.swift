//
//  Extension.swift
//  Extensions
//
//  Created by Matias Piipari on 06/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation
import Freddy
import MPTimer

public protocol ExtensionLike {
    var identifier:String { get }
    var procedures:[Procedure] { get }
}

public typealias ExtensionErrorHandler = (error:ErrorType)->Void

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
    case EvaluationFailed(ErrorType)
    case EvaluationTimedOut(Extension)
}

private class ExtensionState {
    private var procedures:[Procedure]
    private var processable:Processable?
    private var lastError:ErrorType?
    private let procedureHandler:(input:Processable?, output:Processable?) -> Void
    private weak var containingExtension:Extension?
    private var evaluationTimer:Timer<ExtensionState>? = nil
    private var timedOut = false
    
    private init(procedures:[Procedure],
                 processable:Processable?,
                 containingExtension:Extension,
                 procedureHandler:(input:Processable?, output:Processable?) -> Void) {
        self.procedures = procedures
        self.processable = processable
        self.procedureHandler = procedureHandler
        self.containingExtension = containingExtension
    }
}

public final class Extension: ExtensionLike, Hashable, Equatable {
    public let identifier:String
    public let rootURL:NSURL
    public let procedures:[Procedure]
    
    public var hashValue: Int {
        return self.identifier.hashValue ^ rootURL.hashValue ^ procedures.reduce(0) { $0 ^ $1.hashValue }
    }
    
    private static let timeoutInterval:NSTimeInterval = 10.0
    
    public func evaluate(input:Processable?,
                         procedureHandler:(input:Processable?,
                         output:Processable?) -> Void,
                         errorHandler:ExtensionErrorHandler) throws {
        let state = ExtensionState(procedures:self.procedures, processable: input, containingExtension: self, procedureHandler: procedureHandler)
        
        if state.evaluationTimer == nil {
            state.evaluationTimer = Timer(object:state)
        }
        state.evaluationTimer?.after(delay: self.evaluationTimeout) { (state:ExtensionState) in
            let e = ExtensionError.EvaluationTimedOut(self)
            state.lastError = e
            state.timedOut = true
            errorHandler(error: e)
        }
        
        if self.procedures.count == 0 {
            throw ExtensionError.ExtensionHasNoProcedures(self)
        }
        
        let procedure = state.procedures.removeFirst()
        
        let evaluator = try EvaluatorRegistry.sharedInstance.createEvaluator(identifier:procedure.evaluatorID, containingExtension: self)
        
        let contents = try self.sourceContents(procedure)
        evaluator.evaluate(contents, input:input, outputHandler:self.outputHandler(state), errorHandler: self.errorHandler(state))
    }
    
    private var evaluationTimeout:NSTimeInterval {
        return 10.0
    }
    
    // MARK: -
    // MARK: Internals & private parts
    
    internal init(identifier:String, rootURL:NSURL, procedures:[Procedure]) {
        self.identifier = identifier
        self.rootURL = rootURL
        self.procedures = procedures
    }
    
    private func sourceContents(procedure:Procedure) throws -> String {
        let URL = self.rootURL.URLByAppendingPathComponent("Contents/Resources").URLByAppendingPathComponent(procedure.source)
        return try NSString(contentsOfURL: URL, encoding: NSUTF8StringEncoding) as String
    }
    
    private func outputHandler(state:ExtensionState) -> (output: Processable?) -> Void {
        precondition(state.lastError == nil, "State already has lastError set to \(state.lastError)")

        return {
            let input = state.processable
            let output = $0
            
            state.procedureHandler(input: input, output: output)
            
            // replace input with output
            state.processable = output
            
            if state.procedures.count > 0 && !state.timedOut {
                let procedure = state.procedures.removeFirst()
                
                do {
                    let evaluator = try EvaluatorRegistry.sharedInstance.createEvaluator(identifier:procedure.evaluatorID, containingExtension: self)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        evaluator.evaluate(procedure.source, input:input, outputHandler:self.outputHandler(state), errorHandler: self.errorHandler(state))
                    }
                }
                catch {
                    state.lastError = error
                }
            }
        }
    }
    
    private func errorHandler(state:ExtensionState) -> (EvaluatorError) -> Void {
        precondition(state.lastError == nil, "State already has lastError set to \(state.lastError)")
        
        return {
            state.lastError = ExtensionError.EvaluationFailed($0)
        }
    }
}

public func ==(lhs:Extension, rhs:Extension) -> Bool {
    return lhs.identifier == rhs.identifier
}