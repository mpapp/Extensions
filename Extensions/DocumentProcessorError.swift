//
//  HTMLProcessable.swift
//  Manuscripts
//
//  Created by Matias Piipari on 17/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

public enum DocumentProcessorError : Error {
    case referenceIDAttributeMissing(XMLElement)
    case referenceUnresolvable(NSString)
    case unexpectedParentNode(XMLNode?)
    case unexpectedChildIndex(XMLNode)
    case failedToRepresentStringAsData(NSString)
    case unexpectedNodeType(XMLNode)
    case failedToRepresentDataInUTF8(Data)
}

