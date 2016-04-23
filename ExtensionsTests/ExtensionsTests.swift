//
//  ExtensionsTests.swift
//  ExtensionsTests
//
//  Created by Matias Piipari on 06/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import XCTest
import Extensions
import OHHTTPStubs

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
            try ext.evaluate(Processable.StringData("foo"), procedureHandler: { _,_ in
                //print("Input \($0) -> Output:\($1)")
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
        
        stub(isHost("www.rcsb.org")) { (_) in
            let stubPath = OHPathForFile("1HIV.rcsb-xml", self.dynamicType)!
            return fixture(stubPath, headers: [:])
        }
        
        stub(isHost("eutils.ncbi.nlm.nih.gov")) { (_) in
            let stubPath = OHPathForFile("1304383.pubmed-xml", self.dynamicType)!
            return fixture(stubPath, headers: [:])
        }
        
        let pdb = ResolvableElementProcessor(resolver: ProteinDataBankResolver(), tokenizingPatterns: [], capturingPatterns:[ProteinDataBankIdentifier.capturingPattern]) { (textNode, fragment, resolvedResult) in
            print("Text node: \(textNode), fragment:\(fragment), result:\(resolvedResult)")
        }
        let docP = ResolvingDocumentProcessor(resolver: ProteinDataBankResolver(), elementProcessors: [pdb])
        
        let URL:NSURL = NSBundle(forClass: self.dynamicType).URLForResource("biolit", withExtension: "html")!
        
        var doc:NSXMLDocument? = nil
        do {
            doc = try NSXMLDocument(contentsOfURL: URL, options: Extensions.MPDefaultXMLDocumentOutputOptions | NSXMLDocumentTidyHTML)
        }
        catch {
            XCTFail("Failed to initialize test document from URL \(URL).")
        }
        
        do {
            try docP.processedDocument(inputDocument: doc!)
        }
        catch {
            XCTFail("Failed to process document from URL \(URL).")
        }
    
    }
}
