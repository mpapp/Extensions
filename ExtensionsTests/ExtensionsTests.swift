//
//  ExtensionsTests.swift
//  ExtensionsTests
//
//  Created by Matias Piipari on 06/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import XCTest
import Extensions

class ExtensionsTests: XCTestCase {
    
    private var debugWindowController:EvaluatorDebugWindowController?
    
    override func setUp() {
        super.setUp()

        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "WebKitDeveloperExtras")
        EvaluatorDebugWindowController.sharedInstance()        

        let bundleURL = NSBundle(forClass: self.dynamicType).bundleURL
        try! ExtensionRegistry.sharedInstance.loadExtensions(bundleURL, loadFailureHandler:{
            XCTFail("Load failure: \($0)")
        })
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLoadingWebKitExtension() {
        let extensions = ExtensionRegistry.sharedInstance.extensionSet
        XCTAssertTrue(extensions.count > 0, "No extensions have been loaded.")
        
        let ext = try! ExtensionRegistry.sharedInstance.extensionWithIdentifier("com.manuscriptsapp.JSExample")
        
        XCTAssertTrue(ext.procedures.count == 2, "Unexpected procedure count: \(ext.procedures.count) != 2")
        
        let exp = expectationWithDescription("Evaluation ended successfully.")
        
        do {
            try ext.evaluate(Processable.StringData("foo"), procedureHandler: {
                print("Input \($0) -> Output:\($1)")
                exp.fulfill()
            }, errorHandler: {
                XCTFail("Evaluation error: \($0)")
            })
        }
        catch {
            XCTFail("Unexpected evaluation error: \(error)")
        }

        waitForExpectationsWithTimeout(50.0) { (err:NSError?) in
            XCTAssertNil(err, "Unexpected error \(err)")
        }

    }
    
    func testProcessingResolvingPDBIdentifier() {
        let pdb = ResolvableElementProcessor(resolver: ProteinDataBankResolver()) { (textNode, fragment, resolvedResult) in
            print("Text node: \(textNode), fragment:\(fragment), result:\(resolvedResult)")
        }
        let docP = ResolvingDocumentProcessor(resolver: ProteinDataBankResolver(), elementProcessors: [pdb])
        
        let URL:NSURL = NSBundle(forClass: self.dynamicType).URLForResource("biolit", withExtension: "html")!
        let doc = try! NSXMLDocument(contentsOfURL: URL, options: Extensions.MPDefaultXMLDocumentOutputOptions)
    
        try! docP.processedDocument(inputDocument: doc)
    }
}
