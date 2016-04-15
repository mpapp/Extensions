//
//  REvaluator.swift
//  Extensions
//
//  Created by Matias Piipari on 06/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

internal final class REvaluator: NSObject, Evaluator {
    var identifier: String {
        return "org.cran.r"
    }
    
    var fileExtensions: Set<String> {
        return ["R"]
    }
    
    override init() {
        super.init()
    }
    
    convenience init(evaluator: Evaluator, containingExtension:Extension) throws {
        preconditionFailure("Implement in subclass")
    }
    
    func evaluate(source: String, input:Processable?, outputHandler:(Processable?)->Void, errorHandler: (EvaluatorError) -> Void) {
        preconditionFailure()
    }
    
    static func encode(processable: Processable?) -> AnyObject? {
        preconditionFailure("Implement")
    }
    
    static func decode(processable: AnyObject?) -> Processable? {
        preconditionFailure("Implement")
    }
}