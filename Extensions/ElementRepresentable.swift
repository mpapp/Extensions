//
//  ElementRepresentable.swift
//  Extensions
//
//  Created by Matias Piipari on 25/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

public protocol ElementRepresentable {
    func elementRepresentation() throws -> Element
}
