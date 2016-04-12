//
//  EvaluatorDebugWindowController.swift
//  Extensions
//
//  Created by Matias Piipari on 11/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import Cocoa

public class EvaluatorDebugWindowController: NSWindowController {

    @IBOutlet public var debugViewController: EvaluatorDebugViewController!
    
    override public func windowDidLoad() {
        super.windowDidLoad()
        self.window?.contentView?.addSubviewConstrainedToSuperViewEdges(self.debugViewController.view)
    }
    
    // couldn't think of another way of making this lazily initialized?
    private static var _sharedInstance:EvaluatorDebugWindowController? = nil
    
    public static func sharedInstanceExists() -> Bool {
        return _sharedInstance != nil
    }
    
    public static func sharedInstance() -> EvaluatorDebugWindowController {
        if _sharedInstance == nil {
            _sharedInstance = EvaluatorDebugWindowController(windowNibName: "EvaluatorDebugWindowController")
            _sharedInstance!.showWindow(self)
            _sharedInstance!.window?.makeKeyAndOrderFront(self)
        }
        
        return _sharedInstance!
    }
}
