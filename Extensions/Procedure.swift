//
//  Procedure.swift
//  Extensions
//
//  Created by Matias Piipari on 08/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation
import Freddy

public class Procedure {
    let evaluator:Evaluator
    let source:String
    //let resources:Set<NSURL>
    
    required public init(evaluator:Evaluator, source:String, resources:Set<NSURL>) {
        self.evaluator = evaluator
        self.source = source
        //self.resources = resources
    }
    
    public init(json: JSON) throws {
        let evaluatorID = try json.string("evaluator")
        let evaluator = try EvaluatorRegistry.sharedInstance.evaluator(identifier: evaluatorID)
        self.evaluator = evaluator
        
        self.source = try json.string("source")
        //self.resources = Set(try json.array("resources").map {
        //    let path = try $0.string()
        //    return NSURL(fileURLWithPath:path)
        //    })
    }
}