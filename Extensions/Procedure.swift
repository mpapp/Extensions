//
//  Procedure.swift
//  Extensions
//
//  Created by Matias Piipari on 08/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation
import Freddy

class Procedure {
    let evaluator:Evaluator
    let source:String
    let resources:Set<NSURL>
    
    required init(evaluator:Evaluator, source:String, resources:Set<NSURL>) {
        self.evaluator = evaluator
        self.source = source
        self.resources = resources
    }
    
    init(json: JSON) throws {
        let evaluator = try EvaluatorRegistry.sharedInstance.evaluator(identifier: try json.string("evaluator"))
        self.evaluator = evaluator
        
        self.source = try json.string("source")
        self.resources = Set(try json.array("resources").map { return NSURL(fileURLWithPath:try $0.string()) })
    }
}