//
//  JavaScriptEvaluator.swift
//  Extensions
//
//  Created by Matias Piipari on 06/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Foundation
import WebKit
import JavaScriptCore

public class JavaScriptEvaluator:NSObject, Evaluator {
    
    public var identifier: String {
        preconditionFailure("Implement in subclass.")
    }
    
    public var fileExtensions: Set<String> {
        return ["js"]
    }
    
    public func evaluate(source:String, input:Processable, outputHandler:(AnyObject)->Void, errorHandler:(EvaluatorError, String)->Void) {
        preconditionFailure("Override in subclass")
    }
    
    public class func encode(processable:Processable?) -> AnyObject? {
        guard let input = processable else {
            return nil
        }
        
        switch input {
        case .DoubleData(let d):
            return NSNumber(double: d)
        case .IntData(let i):
            return NSNumber(integer:i)
        case .PListEncodableArray(let ps):
            return ps
        case .PListEncodableScalar(let p):
            return p
        case .StringData(let str):
            return str
        }
    }
}

// MARK:
// MARK: WebKit

@objc public class JavaScriptEvaluatorWebKit:JavaScriptEvaluator {
    private let webView:WebView
    
    public let isPresented: Bool
    private var isLoaded: Bool = false
    
    init(webView:WebView? = nil) {
        self.isPresented = webView != nil

        if let webView = webView {
            self.webView = webView
        }
        else {
            self.webView = WebView(frame: NSMakeRect(0, 0, 0, 0))
        }
        
        super.init()
        
        if (!self.isPresented) {
            self.webView.frameLoadDelegate = self
            self.webView.resourceLoadDelegate = self
            self.webView.policyDelegate = self
            self.webView.UIDelegate = self
            self.webView.editingDelegate = self
            self.webView.editable = false
            
            // WUT? Would this help with the issue we have with a "shadow caret"
            //self.webView.maintainsInactiveSelection = false
            self.webView.setMaintainsBackForwardList(false)
        }
        
        let evaluatorHTMLURL = NSBundle(forClass: self.dynamicType).URLForResource("JavaScriptEvaluatorWebKit", withExtension: "html", subdirectory: "JavaScriptEvaluatorWebKit")!
        
        let evaluatorLoadedBlock: @convention(block) (Void) -> Void = {
            self.evaluatorLoaded()
        }
        
        self.webView.mainFrame.loadRequest(NSURLRequest(URL: evaluatorHTMLURL))
        self.webView.mainFrame.javaScriptContext.globalObject.setValue(unsafeBitCast(evaluatorLoadedBlock, AnyObject.self), forProperty: "evaluatorLoaded")
    }
    
    private func evaluatorLoaded() {
        precondition(!self.isLoaded, "Evaluator \(self) should be loaded only once.")
        fputs("JS (WebKit) Evaluator loaded.", stderr)
        self.isLoaded = true
    }
    
    public override var identifier: String {
        return "org.javascript.webkit"
    }
    
    private var completionHandler:WebScriptObject {
        let completionHandler = self.webView.windowScriptObject.callWebScriptMethod("evaluatorCompletionHandler", withArguments: [self.identifier])
        
        guard let completion = completionHandler as? WebScriptObject where !(completionHandler is WebUndefined) else {
            preconditionFailure("Expecting a non-nil completion handler for \(self)")
        }
        
        return completion
    }
    
    private var errorHandler:WebScriptObject {
        let errorHandler = self.webView.windowScriptObject.callWebScriptMethod("evaluatorErrorHandler", withArguments: [self.identifier])
        
        guard let error = errorHandler as? WebScriptObject where !(errorHandler is WebUndefined) else {
            preconditionFailure("Expecting a non-nil completion handler for \(self)")
        }
        
        return error
    }
    
    public override func evaluate(source: String,
                                  input:Processable,
                                  outputHandler: (AnyObject) -> Void,
                                  errorHandler: (EvaluatorError, String) -> Void) {
        
        // needed to wrap the passed in output handler to an Objective-C conventioned block.
        let outputBlock:@convention(block) (AnyObject) -> Void = {
            return outputHandler($0)
        }
        
        // needed to wrap the passed in error handler to an Objective-C conventioned block 
        // (also wrapping the incoming Int typed value to an EvaluatorError).
        let errorBlock:@convention(block) (Int, String) -> Void = {
            return errorHandler(EvaluatorError(rawValue: $0)!, $1)
        }
        
        self.webView.windowScriptObject.setValue(self.dynamicType.encode(input), forKey: "input")
        self.webView.windowScriptObject.setValue(unsafeBitCast(outputBlock, AnyObject.self), forKey:"output")
        self.webView.windowScriptObject.setValue(unsafeBitCast(errorBlock, AnyObject.self), forKey:"error")
        
        self.webView.windowScriptObject.evaluateWebScript(source)

        self.webView.windowScriptObject.setValue(nil, forKey: "input")
        self.webView.windowScriptObject.setValue(nil, forKey: "output")
        self.webView.windowScriptObject.setValue(nil, forKey: "error")
    }
}

extension JavaScriptEvaluatorWebKit: WebFrameLoadDelegate {
    
}

extension JavaScriptEvaluatorWebKit: WebResourceLoadDelegate {
    
}

extension JavaScriptEvaluatorWebKit: WebPolicyDelegate {
    
}

extension JavaScriptEvaluatorWebKit: WebUIDelegate {
    
}

// MARK:
// MARK: JSC

public class JavaScriptEvaluatorJSC: JavaScriptEvaluator {
    public override var identifier: String {
        return "org.javascript.javascriptcore"
    }
}