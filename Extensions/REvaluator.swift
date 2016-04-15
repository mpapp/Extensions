//
//  REvaluator.swift
//  Extensions
//
//  Created by Matias Piipari on 06/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

public final class REvaluator: NSObject, Evaluator {
    public var identifier: String {
        return "org.cran.r"
    }
    
    public var fileExtensions: Set<String> {
        return ["R"]
    }
    
    public override init() {
        super.init()
    }
    
    public convenience init(evaluator: Evaluator, containingExtension:Extension) throws {
        preconditionFailure("Implement in subclass")
    }
    
    public func evaluate(source: String, input:Processable?, outputHandler:(Processable?)->Void, errorHandler: (EvaluatorError) -> Void) {
        preconditionFailure()
    }
    
    public static func encode(processable: Processable?) -> AnyObject? {
        preconditionFailure("Implement")
    }
    
    public static func decode(processable: AnyObject?) -> Processable? {
        preconditionFailure("Implement")
    }
}