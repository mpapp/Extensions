//
//  REvaluator.swift
//  Extensions
//
//  Created by Matias Piipari on 06/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

public class REvaluator: Evaluator {
    override public var identifier: String {
        return "org.cran.r"
    }
    
    override public var fileExtensions: Set<String> {
        return ["R"]
    }
}