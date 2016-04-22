//
//  HTMLProcessable.swift
//  Manuscripts
//
//  Created by Matias Piipari on 17/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation
import RegexKitLite

public enum DocumentProcessorError : ErrorType {
    case ReferenceIDAttributeMissing(NSXMLElement)
    case ReferenceUnresolvable(NSString)
    case UnexpectedParentNode(NSXMLNode?)
    case UnexpectedChildIndex(NSXMLNode)
    case FailedToRepresentStringAsData(NSString)
    case UnexpectedNodeType(NSXMLNode)
    case FailedToRepresentDataInUTF8(NSData)
}

