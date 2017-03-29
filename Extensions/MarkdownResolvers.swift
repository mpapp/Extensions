//
//  MarkdownSyntaxResolver.swift
//  Extensions
//
//  Created by Matias Piipari on 24/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation

open class MarkdownSyntaxComponent: Resolvable, HTMLSnippetRepresentable {
    open let identifier: String
    open let originatingString: String
    
    public required init(originatingString: String) throws {
        // pattern matches paired * *'s in between one or more characters between word boundaries.
        guard (originatingString as NSString).isMatched(byRegex: type(of: self).capturingPattern()) else {
            throw ResolvingError.notResolvable(originatingString)
        }
        
        self.originatingString = originatingString
        self.identifier = self.originatingString
    }
    
    open class func capturingPattern() -> String {
        preconditionFailure("Implement in subclass")
    }
    
    open class func contentCapturingPattern() -> String {
        preconditionFailure("Implement in subclass")
    }
    
    open var tagName: String {
        preconditionFailure("Implement in subclass")
    }
    
    open var innerHTML: String {
        guard let captured = self.identifier.componentsCaptured(capturingPatterns: [type(of: self).contentCapturingPattern()]).first else {
            preconditionFailure("Unexpected identifier \(self.identifier)")
        }
        return captured
    }
    
    open var attributes: [String : String] {
        return [:]
    }
}

public final class MarkdownAsteriskStrong: MarkdownSyntaxComponent {
    public override class func capturingPattern() -> String { return "(\\*\\*.+?\\*\\*)" }
    public override class func contentCapturingPattern() -> String { return "\\*\\*(.+?)\\*\\*" }
    
    public override var tagName: String {
        return "strong"
    }
}

public final class MarkdownUnderscoreStrong: MarkdownSyntaxComponent {
    public override class func capturingPattern() -> String { return "(\\_\\_.+?\\_\\_)" }
    public override class func contentCapturingPattern() -> String { return "\\_\\_(.+?)\\_\\_" }
    
    public override var tagName: String {
        return "strong"
    }
}

public final class MarkdownAsteriskEmphasis: MarkdownSyntaxComponent {
    public override class func capturingPattern() -> String { return "(\\*.+?\\*)" }
    public override class func contentCapturingPattern() -> String { return "\\*(.+?)\\*" }
    
    public override var tagName: String {
        return "em"
    }
}

public final class MarkdownUnderscoreEmphasis: MarkdownSyntaxComponent {
    public override class func capturingPattern() -> String { return "(\\_.+?\\_)" }
    public override class func contentCapturingPattern() -> String { return "\\_(.+?)\\_" }
    
    public override var tagName: String {
        return "em"
    }
}

// MARK:

public struct MarkdownSyntaxComponentResolver:Resolver {
    
    public let resolvableType:Resolvable.Type
    
    public static let identifier:String = "org.markdown.component"
    
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

    public func resolve(_ string: String) throws -> ResolvedResult {
        let identifier:MarkdownSyntaxComponent = try self.markdownComponentType.init(originatingString: string)
        let item = SimpleInlineElement(contents: identifier.innerHTML, tagName: identifier.tagName)
        
        return ResolvedResult(resolvable: identifier, result:.inlineElements([item]))
    }
}
