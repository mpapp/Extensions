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
    
    override func setUp() {
        super.setUp()
        
        let bundleURL = NSBundle(forClass: self.dynamicType).bundleURL
        try! ExtensionRegistry.sharedInstance.loadExtensions(bundleURL)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testResolvingWebKitEvaluator() {
        try! EvaluatorRegistry.sharedInstance.evaluator(identifier: "org.javascript.webkit")
    }
    
    func testLoadingWebKitExtension() {
        let extensions = ExtensionRegistry.sharedInstance.extensionSet
        XCTAssertTrue(extensions.count > 0, "No extensions have been loaded.")
        
        let ext = try! ExtensionRegistry.sharedInstance.extensionWithIdentifier("com.manuscriptsapp.JSExample")
        
        XCTAssertTrue(ext.procedures.count == 2, "Unexpected procedure count: \(ext.procedures.count) != 2")
        
        try ext.evaluate(<#T##input: Processable##Processable#>, procedureHandler: <#T##(input: Processable) -> Processable#>, errorHandler: <#T##(error: ErrorType) -> Void#>)
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
}
