//
//  REvaluator.swift
//  Extensions
//
//  Created by Matias Piipari on 06/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

public class REvaluator: NSObject {
    public var identifier: String {
        return "org.cran.r"
    }
    
    public var fileExtensions: Set<String> {
        return ["R"]
    }
}

extension REvaluator: Evaluator {
    public func evaluate(source: String, input:Processable, outputHandler:(AnyObject)->Void, errorHandler: (EvaluatorError, String) -> Void) {
        preconditionFailure()
    }
}