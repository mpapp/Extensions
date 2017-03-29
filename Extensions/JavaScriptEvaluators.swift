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

    static func decode(_ propertyListEncoded:Any?) -> Processable? {
        if let n = propertyListEncoded as? NSNumber {
            if n.isFloatingPoint {
                return .doubleData(n.doubleValue)
            }
            else if n.isBoolean {
                return .boolData(n.boolValue)
            }
            else {
                return .intData(n.intValue)
            }
        }
        else if let s = propertyListEncoded as? String {
            return .stringData(s)
        }
        else if let a = propertyListEncoded as? [AnyObject] {
            return .pListEncodableArray(a)
        }
        else if let propertyListEncoded = propertyListEncoded {
            return .pListEncodableScalar(propertyListEncoded)
        }
        else {
            return nil
        }
    }

    static func encode(_ processable:Processable?) -> Any? {
        guard let input = processable else {
            return NSNull()
        }
        
        switch input {
        case .doubleData(let d):
            return NSNumber(value: d as Double)
        
        case .intData(let i):
            return NSNumber(value: i as Int)
        
        case .boolData(let b):
            return NSNumber(value: b as Bool)
            
        case .pListEncodableArray(let ps):
            return ps
        
        case .pListEncodableScalar(let p):
            return p
        
        case .stringData(let str):
            return str
        }
    }
}

// MARK:
// MARK: WebKit

enum JavaScriptEvaluatorWebKitError:Error {
    case invalidEvaluator(Evaluator)
    case missingContainingExtension(Evaluator)
    case missingResource(URL)
}

typealias OutputHandlerBlock = @convention(block) (AnyObject?) -> Void
typealias InputHandlerBlock = @convention(block) (AnyObject?, OutputHandlerBlock) -> Void
//typealias ErrorHandlerBlock = @convention(block) (Int, String) -> Void

final class JavaScriptEvaluatorWebKit:NSObject, JavaScriptEvaluator, WebEditingDelegate {
    fileprivate(set) internal var webView:WebView
    fileprivate(set) internal var isPresented: Bool
    
    internal(set) internal weak var containingExtension:Extension?
    
    fileprivate var isLoaded: Bool = false
    
    internal var fileExtensions: Set<String> {
        return ["js"]
    }
    
    internal required init(evaluator: Evaluator, containingExtension:Extension) throws {
        guard let jsEvaluator = evaluator as? JavaScriptEvaluatorWebKit else {
            throw JavaScriptEvaluatorWebKitError.invalidEvaluator(evaluator)
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
    
    fileprivate class func initialize(_ webView:WebView?) -> (isPresented:Bool, webView:WebView) {
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
    
    fileprivate func load() throws -> Void {
        if (!self.isPresented) {
            self.webView.frameLoadDelegate = self
            self.webView.resourceLoadDelegate = self
            self.webView.policyDelegate = self
            self.webView.uiDelegate = self
            self.webView.editingDelegate = self
            self.webView.isEditable = false
            
            // WUT? Would this help with the issue we have with a "shadow caret"
            //self.webView.maintainsInactiveSelection = false
            
            self.webView.setMaintainsBackForwardList(false)
        }
        
        guard let evaluatorHTMLURL = self.containingExtension?.rootURL.appendingPathComponent("Contents/Resources/index.html") else {
            throw JavaScriptEvaluatorWebKitError.missingContainingExtension(self)
        }
        
        let evaluatorLoadedBlock: @convention(block) (Void) -> Void = {
            self.evaluatorLoaded()
        }
        
        if evaluatorHTMLURL.isFileURL {
            let path = evaluatorHTMLURL.path
            guard FileManager.default.fileExists(atPath: path) else {
                throw JavaScriptEvaluatorWebKitError.missingResource(evaluatorHTMLURL)
            }
        }
        
        self.webView.mainFrame.javaScriptContext.globalObject.setValue(
            unsafeBitCast(evaluatorLoadedBlock, to: AnyObject.self), forProperty: "evaluatorLoaded")
        
        self.webView.mainFrame.javaScriptContext.exceptionHandler = { context, exception in
            print("JS Exception during loading: \(exception)\n\(context)");
        }
        
        self.webView.mainFrame.load(URLRequest(url: evaluatorHTMLURL))
    }
    
    fileprivate func evaluatorLoaded() {
        precondition(!self.isLoaded, "Evaluator \(self) should be loaded only once.")
        print("JS (WebKit) Evaluator loaded.")
        self.isLoaded = true
    }
    
    var identifier: String {
        return "org.javascript.webkit"
    }
    
    func evaluate(_ source: String,
                         input:Processable?,
                         outputHandler: @escaping (Processable?) -> Void,
                         errorHandler: @escaping (EvaluatorError) -> Void) {
        while !self.isLoaded {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before:Date(timeIntervalSinceNow:0.01))
        }
        
        precondition(self.isLoaded, "Evaluator should already be loaded.")
        
        // needed to wrap the passed in output handler to an Objective-C conventioned block.
        let outputBlock:OutputHandlerBlock = {
            if let decodedVal = type(of: self).decode($0) {
                return outputHandler(decodedVal)
            }
            else {
                errorHandler(EvaluatorError.missingReturnValue)
            }
        }

        DispatchQueue.main.async {
            let exportsDict = NSMutableDictionary()
            
            self.webView.mainFrame.javaScriptContext.globalObject.setValue(exportsDict, forProperty: "exports")
            
            self.webView.mainFrame.javaScriptContext.exceptionHandler = { context, exception in
                print("JS Exception during loading: \(exception)\n\(context)")
                errorHandler(EvaluatorError.evaluationFailed(self.containingExtension, self, exception))
            }
            
            self.webView.windowScriptObject.evaluateWebScript(source)

            guard let encodedInput = type(of: self).encode(input) else {
                errorHandler(EvaluatorError.unexpectedNilInput(self.containingExtension, self))
                return
            }
            
            guard let processFunc = self.webView.mainFrame.javaScriptContext.globalObject.forProperty("exports").forProperty("process") else {
                errorHandler(EvaluatorError.missingProcessFunction(self.containingExtension, self))
                return
            }
            
            processFunc.call(withArguments: [encodedInput, unsafeBitCast(outputBlock, to: AnyObject.self)])
            
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
    
    func evaluate(_ source: String,
                  input: Processable?,
                  outputHandler: @escaping (Processable?) -> Void,
                  errorHandler: @escaping (EvaluatorError) -> Void) {
        preconditionFailure("Implement me.")
    }
}
