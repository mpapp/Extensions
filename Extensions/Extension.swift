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

public typealias ExtensionErrorHandler = (_ error:Error)->Void

public enum ExtensionError:Error {
    case missingEvaluatorKey
    case invalidEvaluatorClass(String)
    case invalidEvaluatorType(AnyClass?)
    case notPropertyList([String:Any])
    case missingInfoDictionary(Bundle)
    case invalidExtensionAtURL(URL)
    case extensionFailedToLoad(Bundle)
    case underlyingError(Error)
    case extensionHasNoProcedures(Extension)
    case evaluationFailed(Error)
    case evaluationTimedOut(Extension)
}

private class ExtensionState {
    fileprivate var procedures:[Procedure]
    fileprivate var processable:Processable?
    fileprivate var lastError:Error?
    fileprivate let procedureHandler:(_ input:Processable?, _ output:Processable?) -> Void
    fileprivate weak var containingExtension:Extension?
    
    fileprivate var evaluationTimer: MPTimer.Timer<ExtensionState>? = nil
    fileprivate var timedOut = false
    
    fileprivate init(procedures:[Procedure],
                 processable:Processable?,
                 containingExtension:Extension,
                 procedureHandler:@escaping (_ input:Processable?, _ output:Processable?) -> Void) {
        self.procedures = procedures
        self.processable = processable
        self.procedureHandler = procedureHandler
        self.containingExtension = containingExtension
    }
}

public typealias ProcedureHandler = (_ input:Processable?, _ output:Processable?) -> Void

public final class Extension: ExtensionLike, Hashable, Equatable {
    public let identifier:String
    public let rootURL:URL
    public let procedures:[Procedure]
    
    public var hashValue: Int {
        return self.identifier.hashValue ^ rootURL.hashValue ^ procedures.reduce(0) { $0 ^ $1.hashValue }
    }
    
    fileprivate static let timeoutInterval:TimeInterval = 10.0
    
    public func evaluate(_ input:Processable?,
                         procedureHandler:@escaping ProcedureHandler,
                         errorHandler:@escaping ExtensionErrorHandler) throws {
        let state = ExtensionState(procedures:self.procedures, processable: input, containingExtension: self, procedureHandler: procedureHandler)
        
        let timer: MPTimer.Timer<ExtensionState>
            
        if let t = state.evaluationTimer {
            timer = t
        }
        else {
            timer = MPTimer.Timer<ExtensionState>(object: state)
            state.evaluationTimer = timer
        }
        
        timer.after(delay: self.evaluationTimeout) { (state: ExtensionState) in
            let e = ExtensionError.evaluationTimedOut(self)
            state.lastError = e
            state.timedOut = true
            errorHandler(e)
        }
        
        if self.procedures.count == 0 {
            throw ExtensionError.extensionHasNoProcedures(self)
        }
        
        let procedure = state.procedures.removeFirst()
        
        let evaluator = try EvaluatorRegistry.sharedInstance.createEvaluator(identifier:procedure.evaluatorID, containingExtension: self)
        
        let contents = try self.sourceContents(procedure)
        evaluator.evaluate(contents, input:input, outputHandler:self.outputHandler(state), errorHandler: self.errorHandler(state))
    }
    
    fileprivate var evaluationTimeout:TimeInterval {
        return 10.0
    }
    
    // MARK: -
    // MARK: Internals & private parts
    
    internal init(identifier:String, rootURL:URL, procedures:[Procedure]) {
        self.identifier = identifier
        self.rootURL = rootURL
        self.procedures = procedures
    }
    
    fileprivate func sourceContents(_ procedure:Procedure) throws -> String {
        let URL = self.rootURL.appendingPathComponent("Contents/Resources").appendingPathComponent(procedure.source)
        return try String(contentsOf: URL, encoding: .utf8)
    }
    
    fileprivate func outputHandler(_ state:ExtensionState) -> (_ output: Processable?) -> Void {
        precondition(state.lastError == nil, "State already has lastError set to \(state.lastError)")

        return {
            let input = state.processable
            let output = $0
            
            state.procedureHandler(input, output)
            
            // replace input with output
            state.processable = output
            
            if state.procedures.count > 0 && !state.timedOut {
                let procedure = state.procedures.removeFirst()
                
                do {
                    let evaluator = try EvaluatorRegistry.sharedInstance.createEvaluator(identifier:procedure.evaluatorID, containingExtension: self)
                    
                    DispatchQueue.main.async {
                        evaluator.evaluate(procedure.source, input:input, outputHandler:self.outputHandler(state), errorHandler: self.errorHandler(state))
                    }
                }
                catch {
                    state.lastError = error
                }
            }
        }
    }
    
    fileprivate func errorHandler(_ state:ExtensionState) -> (EvaluatorError) -> Void {
        precondition(state.lastError == nil, "State already has lastError set to \(state.lastError)")
        
        return {
            state.lastError = ExtensionError.evaluationFailed($0)
        }
    }
}

public func ==(lhs:Extension, rhs:Extension) -> Bool {
    return lhs.identifier == rhs.identifier
}
