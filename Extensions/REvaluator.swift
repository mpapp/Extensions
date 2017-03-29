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
    
    
    func evaluate(_ source: String, input:Processable?, outputHandler:@escaping (Processable?)->Void, errorHandler: @escaping (EvaluatorError) -> Void) {
        preconditionFailure()
    }
    
    static func encode(_ processable: Processable?) -> Any? {
        preconditionFailure("Implement")
    }
    
    static func decode(_ processable: Any?) -> Processable? {
        preconditionFailure("Implement")
    }
}
