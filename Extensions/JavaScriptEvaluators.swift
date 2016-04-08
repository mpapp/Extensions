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
    
    public func evaluate(input:String, outputHandler:(AnyObject)->Void, errorHandler:(EvaluatorError, String)->Void) throws {
        preconditionFailure("Implement in subclass")
    }
}

// MARK:
// MARK: WebKit

@objc public class JavaScriptEvaluatorWebKit:JavaScriptEvaluator {
    private let webView:WebView
    
    public let isPresented: Bool
    
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
    }
    
    public override var identifier: String {
        return "org.javascript.webkit"
    }
    
    public override func evaluate(input: String, outputHandler: (AnyObject) -> Void, errorHandler: (EvaluatorError, String) -> Void) throws {
        
        // needed to wrap the passed in output handler to an Objective-C conventioned block.
        let outputBlock:@convention(block) (AnyObject) -> Void = {
            return outputHandler($0)
        }
        
        // needed to wrap the passed in error handler to an Objective-C conventioned block 
        // (also wrapping the incoming Int typed value to an EvaluatorError).
        let errorBlock:@convention(block) (Int, String) -> Void = {
            return errorHandler(EvaluatorError(rawValue: $0)!, $1)
        }
        
        self.webView.windowScriptObject.callWebScriptMethod("setEvaluatorCompletionHandler",
                                                            withArguments: [self.identifier, unsafeBitCast(outputBlock, AnyObject.self)])
        
        self.webView.windowScriptObject.callWebScriptMethod("setEvaluatorErrorHandler",
                                                            withArguments: [self.identifier, unsafeBitCast(errorBlock, AnyObject.self)])
        
        self.webView.windowScriptObject.evaluateWebScript(input)
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