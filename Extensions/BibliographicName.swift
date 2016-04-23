//
//  BibliographicName.swift
//  Extensions
//
//  Created by Matias Piipari on 23/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

@objc public protocol BibliographicName: DictionaryRepresentable {
    var family:String? { get }
    var given:String? { get }
    
    var droppingParticle:String? { get }
    var nonDroppingParticle:String? { get }
    
    var suffix:String? { get }
    var literal:String? { get }
}