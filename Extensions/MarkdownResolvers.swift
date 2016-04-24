//
//  MarkdownSyntaxResolver.swift
//  Extensions
//
//  Created by Matias Piipari on 24/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

public class MarkdownSyntaxComponent: Resolvable {
    public let identifier: String
    
    public required init(identifier: String) throws {
        // pattern matches paired * *'s in between one or more characters between word boundaries.
        guard (identifier as NSString).isMatchedByRegex(self.dynamicType.capturingPattern()) else {
            throw ResolvingError.NotResolvable(identifier)
        }
        
        self.identifier = identifier
    }
    
    public class func capturingPattern() -> String {
        preconditionFailure("Implement in subclass")
    }
}

public final class MarkdownAsteriskStrong: MarkdownSyntaxComponent {
    public override class func capturingPattern() -> String { return "\\b\\*\\*(^\\*+)\\*\\*\\b" }
}

public final class MarkdownUnderscoreStrong: MarkdownSyntaxComponent {
    public override class func capturingPattern() -> String { return "\\b\\_\\_(^\\_+)\\_\\_\\b" }
}

public final class MarkdownAsteriskEmphasis: MarkdownSyntaxComponent {
    public override class func capturingPattern() -> String { return "\\b\\*(^\\*)+\\*\\b" }
}

public final class MarkdownUnderscoreEmphasis: MarkdownSyntaxComponent {
    public override class func capturingPattern() -> String { return "\\b\\_(^\\_+)\\_\\b" }
}