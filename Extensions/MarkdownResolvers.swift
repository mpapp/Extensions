//
//  MarkdownSyntaxResolver.swift
//  Extensions
//
//  Created by Matias Piipari on 24/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

public class MarkdownSyntaxComponent: Resolvable, HTMLSnippetRepresentable {
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
    
    public class var tagName: String {
        preconditionFailure("Implement in subclass")
    }
    
    public var innerHTML: String {
        guard let captured = self.identifier.componentsCaptured(capturingPatterns: [self.dynamicType.capturingPattern()]).first else {
            preconditionFailure("Unexpected identifier \(self.identifier)")
        }
        return captured
    }
    
    public var HTMLSnippetRepresentation: String {
        return "<\(self.dynamicType.tagName)>\(self.innerHTML)</\(self.dynamicType.tagName)>"
    }

}

public final class MarkdownAsteriskStrong: MarkdownSyntaxComponent {
    public override class func capturingPattern() -> String { return "\\b\\*\\*(^\\*+)\\*\\*\\b" }
    
    public override class var tagName: String {
        return "strong"
    }
}

public final class MarkdownUnderscoreStrong: MarkdownSyntaxComponent {
    public override class func capturingPattern() -> String { return "\\b\\_\\_(^\\_+)\\_\\_\\b" }
    
    public override class var tagName: String {
        return "strong"
    }
}

public final class MarkdownAsteriskEmphasis: MarkdownSyntaxComponent {
    public override class func capturingPattern() -> String { return "\\b\\*(^\\*)+\\*\\b" }
    
    public override class var tagName: String {
        return "em"
    }
}

public final class MarkdownUnderscoreEmphasis: MarkdownSyntaxComponent {
    public override class func capturingPattern() -> String { return "\\b\\_(^\\_+)\\_\\b" }
    
    public override class var tagName: String {
        return "em"
    }
}

// MARK:

public struct MarkdownSyntaxComponentResolver:Resolver {
    
    public let resolvableType:Resolvable.Type
    
    public init(markdownComponentType:MarkdownSyntaxComponent.Type) {
        self.resolvableType = markdownComponentType
        precondition(self.resolvableType == self.markdownComponentType, "Unexpected Markdown component type: \(self.markdownComponentType)")
    }
    
    public var markdownComponentType:MarkdownSyntaxComponent.Type {
        guard let markdownType = self.resolvableType as? MarkdownSyntaxComponent.Type else {
            preconditionFailure("Unexpected resolvable type \(self.resolvableType) is not subclass of MarkdownSyntaxComponent")
        }
        
        return markdownType
    }

    public func resolve(identifier: String) throws -> ResolvedResult {
        let identifier:MarkdownSyntaxComponent = try self.markdownComponentType.init(identifier: identifier)
        return ResolvedResult.InlineElements([SimpleInlineElement(contents: identifier.HTMLSnippetRepresentation, tagName: identifier.dynamicType.tagName)])
    }
}