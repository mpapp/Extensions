//
//  Extension.swift
//  Extensions
//
//  Created by Matias Piipari on 06/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

@objc public class Extension: NSObject {
    var identifier:String {
        fatalError("Implement in subclass")
    }
    
    var evaluator:Evaluator {
        fatalError("Implement in subclass")
    }
}