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

internal protocol JavaScriptEvaluator:Evaluator { }

extension JavaScriptEvaluator {

    static func decode(propertyListEncoded:AnyObject?) -> Processable? {
        if let n = propertyListEncoded as? NSNumber {
            if n.isFloatingPoint {
                return .DoubleData(n.doubleValue)
            }
            else if n.isBoolean {
                return .BoolData(n.boolValue)
            }
            else {
                return .IntData(n.integerValue)
            }
        }
        else if let s = propertyListEncoded as? String {
            return .StringData(s)
        }
        else if let a = propertyListEncoded as? [AnyObject] {
            return .PListEncodableArray(a)
        }
        else if let propertyListEncoded = propertyListEncoded {
            return .PListEncodableScalar(propertyListEncoded)
        }
        else {
            return nil
        }
    }

    static func encode(processable:Processable?) -> AnyObject? {
        guard let input = processable else {
            return NSNull()
        }
        
        switch input {
        case .DoubleData(let d):
            return NSNumber(double: d)
        
        case .IntData(let i):
            return NSNumber(integer:i)
        
        case .BoolData(let b):
            return NSNumber(bool: b)
            
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

enum JavaScriptEvaluatorWebKitError:ErrorType {
    case InvalidEvaluator(Evaluator)
    case MissingContainingExtension(Evaluator)
    case MissingResource(NSURL)
}

typealias OutputHandlerBlock = @convention(block) (AnyObject?) -> Void
typealias InputHandlerBlock = @convention(block) (AnyObject?, OutputHandlerBlock) -> Void
//typealias ErrorHandlerBlock = @convention(block) (Int, String) -> Void

@objc final class JavaScriptEvaluatorWebKit:NSObject, JavaScriptEvaluator {
    private(set) internal var webView:WebView
    private(set) internal var isPresented: Bool
    
    internal(set) internal weak var containingExtension:Extension?
    
    private var isLoaded: Bool = false
    
    internal var fileExtensions: Set<String> {
        return ["js"]
    }
    
    internal required init(evaluator: Evaluator, containingExtension:Extension) throws {
        guard let jsEvaluator = evaluator as? JavaScriptEvaluatorWebKit else {
            throw JavaScriptEvaluatorWebKitError.InvalidEvaluator(evaluator)
        }
        
        self.containingExtension = containingExtension
        
        (self.isPresented, self.webView) = JavaScriptEvaluatorWebKit.initialize(jsEvaluator.webView)
        if self.isPresented && jsEvaluator.isLoaded {
            self.isLoaded = true
        }
        
        super.init()
    
        if !self.isLoaded {
            try self.load()
        }
    }
    
    private class func initialize(webView:WebView?) -> (isPresented:Bool, webView:WebView) {
        var returnedWebView:WebView
        var isPresented:Bool = webView != nil
        
        if !isPresented && EvaluatorDebugWindowController.sharedInstanceExists() {
            isPresented = true
        }
    
        if let webView = webView {
            returnedWebView = webView
        }
        else {
            if isPresented {
                returnedWebView = EvaluatorDebugWindowController.sharedInstance().debugViewController.webView
            }
            else {
                returnedWebView = WebView(frame: NSMakeRect(0, 0, 0, 0))
            }
        }
        
        return (isPresented, returnedWebView)
    }
    
    internal required init(webView:WebView? = nil) throws {
        
        (self.isPresented, self.webView) = JavaScriptEvaluatorWebKit.initialize(webView)
        
        super.init()
        
        //try self.load()
    }
    
    private func load() throws -> Void {
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
        
        guard let evaluatorHTMLURL = self.containingExtension?.rootURL.URLByAppendingPathComponent("Contents/Resources/index.html") else {
            throw JavaScriptEvaluatorWebKitError.MissingContainingExtension(self)
        }
        
        let evaluatorLoadedBlock: @convention(block) (Void) -> Void = {
            self.evaluatorLoaded()
        }
        
        if evaluatorHTMLURL.fileURL {
            guard let path = evaluatorHTMLURL.path where NSFileManager.defaultManager().fileExistsAtPath(path) else {
                throw JavaScriptEvaluatorWebKitError.MissingResource(evaluatorHTMLURL)
            }
        }
        
        self.webView.mainFrame.javaScriptContext.globalObject.setValue(
            unsafeBitCast(evaluatorLoadedBlock, AnyObject.self), forProperty: "evaluatorLoaded")
        
        self.webView.mainFrame.javaScriptContext.exceptionHandler = { context, exception in
            print("JS Exception during loading: \(exception)\n\(context)");
        }
        
        self.webView.mainFrame.loadRequest(NSURLRequest(URL: evaluatorHTMLURL))
    }
    
    private func evaluatorLoaded() {
        precondition(!self.isLoaded, "Evaluator \(self) should be loaded only once.")
        print("JS (WebKit) Evaluator loaded.")
        self.isLoaded = true
    }
    
    var identifier: String {
        return "org.javascript.webkit"
    }
    
    func evaluate(source: String,
                         input:Processable?,
                         outputHandler: (Processable?) -> Void,
                         errorHandler: (EvaluatorError) -> Void) {
        while !self.isLoaded {
            NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate:NSDate(timeIntervalSinceNow:0.01))
        }
        
        precondition(self.isLoaded, "Evaluator should already be loaded.")
        
        // needed to wrap the passed in output handler to an Objective-C conventioned block.
        let outputBlock:OutputHandlerBlock = {
            if let decodedVal = self.dynamicType.decode($0) {
                return outputHandler(decodedVal)
            }
            else {
                errorHandler(EvaluatorError.MissingReturnValue)
            }
        }

        dispatch_async(dispatch_get_main_queue()) {
            let exportsDict = NSMutableDictionary()
            
            self.webView.mainFrame.javaScriptContext.globalObject.setValue(exportsDict, forProperty: "exports")
            
            self.webView.mainFrame.javaScriptContext.exceptionHandler = { context, exception in
                print("JS Exception during loading: \(exception)\n\(context)")
                errorHandler(EvaluatorError.EvaluationFailed(self.containingExtension, self, exception))
            }
            
            self.webView.windowScriptObject.evaluateWebScript(source)

            guard let encodedInput = self.dynamicType.encode(input) else {
                errorHandler(EvaluatorError.UnexpectedNilInput(self.containingExtension, self))
                return
            }
            
            guard let processFunc = self.webView.mainFrame.javaScriptContext.globalObject.valueForProperty("exports").valueForProperty("process") else {
                errorHandler(EvaluatorError.MissingProcessFunction(self.containingExtension, self))
                return
            }
            
            processFunc.callWithArguments([encodedInput, unsafeBitCast(outputBlock, AnyObject.self)])
            
            self.webView.mainFrame.javaScriptContext.globalObject.setValue(nil, forProperty: "exports")
        }
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

public final class JavaScriptEvaluatorJSC: NSObject, JavaScriptEvaluator {
    
    internal(set) public weak var containingExtension:Extension?
    
    public var identifier: String {
        return "org.javascript.javascriptcore"
    }
    
    public var fileExtensions: Set<String> {
        return ["js"]
    }
    
    public override init() {
        super.init()
    }

    init(evaluator: Evaluator, containingExtension:Extension) throws {
        preconditionFailure("Implement")
    }
    
    func evaluate(source: String,
                  input: Processable?,
                  outputHandler: (Processable?) -> Void,
                  errorHandler: (EvaluatorError) -> Void) {
        preconditionFailure("Implement me.")
    }
}