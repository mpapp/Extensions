//
//  DictionaryRepresentable.swift
//  Extensions
//
//  Created by Matias Piipari on 22/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

public protocol DictionaryRepresentable {
    var dictionaryRepresentation:[String:AnyObject] { get }
}