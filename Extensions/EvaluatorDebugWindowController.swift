//
//  EvaluatorDebugWindowController.swift
//  Extensions
//
//  Created by Matias Piipari on 11/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Cocoa

open class EvaluatorDebugWindowController: NSWindowController {

    @IBOutlet open var debugViewController: EvaluatorDebugViewController!
    
    override open func windowDidLoad() {
        super.windowDidLoad()
        self.window?.contentView?.mp_addSubviewConstrainedToSuperViewEdges(self.debugViewController.view)
    }
    
    // couldn't think of another way of making this lazily initialized?
    fileprivate static var _sharedInstance:EvaluatorDebugWindowController? = nil
    
    open static func sharedInstanceExists() -> Bool {
        return _sharedInstance != nil
    }
    
    open static func sharedInstance() -> EvaluatorDebugWindowController {
        if _sharedInstance == nil {
            _sharedInstance = EvaluatorDebugWindowController(windowNibName: "EvaluatorDebugWindowController")
            _sharedInstance!.showWindow(self)
            _sharedInstance!.window?.makeKeyAndOrderFront(self)
        }
        
        return _sharedInstance!
    }
}
