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
        
        let pdb = ResolvableElementProcessor(resolver: ProteinDataBankResolver(), tokenizingPatterns: [], capturingPatterns:[ProteinDataBankIdentifier.capturingPattern()]) { (elemProcessor, textNode, fragment, resolvedResult) in
            switch resolvedResult {
            case .BibliographyItems(let items):
                XCTAssert(items.count == 1, "Unexpected number of items resolved: \(items)")
                XCTAssert(items.first?.title == "Crystal structure of a complex of HIV-1 protease with a dihydroxyethylene-containing inhibitor: comparisons with molecular modeling.", "Unexpected title: '\(items.first?.title)'")
            default:
                XCTFail("Failed to resolve a bibliography item for \(fragment)")
            }
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
    
    func testResolvingDOI() {
        stub(isHost("dx.doi.org")) { (_) in
            let stubPath = OHPathForFile("10.1038-nrd842.citeproc-json", self.dynamicType)!
            return fixture(stubPath, headers: [:])
        }
        
        let DOIResolver = DigitalObjectIdentifierResolver()
        
        switch try! DOIResolver.resolve("10.1038/nrd84") {
        case .BibliographyItems(let items):
            XCTAssert(items.count == 1, "Unexpected item count \(items.count)")
        default:
            XCTFail("Failed to parse bibliography items.")
        }
        
        let DOIProcessor = ResolvableElementProcessor(resolver: DOIResolver,
                                                      tokenizingPatterns: [],
                                                      capturingPatterns:[DigitalObjectIdentifier.capturingPattern()]) { (elemProcessor, textNode, fragment, resolvedResult) in
            switch resolvedResult {
            case .BibliographyItems(let items):
                XCTAssert(items.count == 1, "Unexpected number of items resolved: \(items)")
                XCTAssert(items.first?.title == "From the analyst\'s couch: Selective anticancer drugs", "Unexpected title: '\(items.first?.title)'")
            default:
                XCTFail("Failed to resolve a bibliography item for \(fragment)")
            }
            print("Text node: \(textNode), fragment:\(fragment), result:\(resolvedResult)")
        }
        let docP = ResolvingDocumentProcessor(resolver: DOIResolver, elementProcessors: [DOIProcessor])
        
        var doc:NSXMLDocument? = nil
        let URL:NSURL = NSBundle(forClass: self.dynamicType).URLForResource("biolit", withExtension: "html")!
        do { doc = try NSXMLDocument(contentsOfURL: URL, options: Extensions.MPDefaultXMLDocumentOutputOptions | NSXMLDocumentTidyHTML) }
        catch { XCTFail("Failed to initialize test document from URL \(URL).") }
        
        do {
            try docP.processedDocument(inputDocument: doc!)
        }
        catch {
            XCTFail("Failed to process document from URL \(URL).")
        }
    }
    
    func testResolvingMarkdown() {
        do { try MarkdownSyntaxComponentResolver(markdownComponentType:MarkdownAsteriskStrong.self).resolve("**foobar**") }
        catch (let error) { XCTFail("Error: \(error)") }
        
        do { try MarkdownSyntaxComponentResolver(markdownComponentType:MarkdownAsteriskEmphasis.self).resolve("*foobar*") }
        catch (let error) { XCTFail("Error: \(error)") }
        
        do { try MarkdownSyntaxComponentResolver(markdownComponentType:MarkdownUnderscoreStrong.self).resolve("__foobar__") }
        catch (let error) { XCTFail("Error: \(error)") }
        
        do { try MarkdownSyntaxComponentResolver(markdownComponentType:MarkdownUnderscoreEmphasis.self).resolve("_foobar_") }
        catch (let error) { XCTFail("Error: \(error)") }
    }
    
    func testProcessingMarkdown() {
        let resolvers:[Resolver] = [MarkdownSyntaxComponentResolver(markdownComponentType:MarkdownAsteriskStrong.self),
                                    MarkdownSyntaxComponentResolver(markdownComponentType:MarkdownUnderscoreStrong.self),
                                    MarkdownSyntaxComponentResolver(markdownComponentType:MarkdownAsteriskEmphasis.self),
                                    MarkdownSyntaxComponentResolver(markdownComponentType:MarkdownUnderscoreEmphasis.self)]
        
        let docP = ResolvingCompoundDocumentProcessor(resolvers: resolvers) { (elementProcessor, textNode, fragment, resolvedResult) in
            print("\(fragment), \(resolvedResult)")
        }

        var doc:NSXMLDocument? = nil
        let URL:NSURL = NSBundle(forClass: self.dynamicType).URLForResource("biolit", withExtension: "html")!
        do { doc = try NSXMLDocument(contentsOfURL: URL, options: Extensions.MPDefaultXMLDocumentOutputOptions | NSXMLDocumentTidyHTML) }
        catch { XCTFail("Failed to initialize test document from URL \(URL).") }
        
        try! docP.processedDocument(inputDocument: doc!)
    }
}
