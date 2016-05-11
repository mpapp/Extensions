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

extension String {
    func stringAroundOccurrence(ofString str:String, maxPadding:UInt, options:NSStringCompareOptions = []) -> String? {
        guard let range = self.rangeOfString(str, options:options, range: nil, locale: nil) else {
            return nil
        }
        
        let p = Int(maxPadding)
        let r = range.startIndex.advancedBy(-p, limit: self.startIndex) ..< range.endIndex.advancedBy(p, limit: self.endIndex)
        return self.substringWithRange(r)
    }
}

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
        
        let pdb = ResolvableElementProcessor(resolver: ProteinDataBankResolver(), tokenizingPatterns: [], capturingPatterns:[ProteinDataBankIdentifier.capturingPattern()])
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
            try docP.processedDocument(inputDocument: doc!, inPlace:true) { (elemProcessor, textNode, fragment, resolvedResult) in
                switch resolvedResult.result {
                case .BibliographyItems(let items):
                    XCTAssert(items.count == 1, "Unexpected number of items resolved: \(items)")
                    XCTAssert(items.first?.title == "Crystal structure of a complex of HIV-1 protease with a dihydroxyethylene-containing inhibitor: comparisons with molecular modeling.", "Unexpected title: '\(items.first?.title)'")
                default:
                    XCTFail("Failed to resolve a bibliography item for \(fragment)")
                }
                print("Text node: \(textNode), fragment:\(fragment), result:\(resolvedResult)")
            }
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
        
        switch try! DOIResolver.resolve("10.1038/nrd84").result {
        case .BibliographyItems(let items):
            XCTAssert(items.count == 1, "Unexpected item count \(items.count)")
        default:
            XCTFail("Failed to parse bibliography items.")
        }
        
        let DOIProcessor = ResolvableElementProcessor(resolver: DOIResolver,
                                                      tokenizingPatterns: [],
                                                      capturingPatterns:[DigitalObjectIdentifier.capturingPattern()])
        let docP = ResolvingDocumentProcessor(resolver: DOIResolver, elementProcessors: [DOIProcessor])
        
        var doc:NSXMLDocument? = nil
        let URL:NSURL = NSBundle(forClass: self.dynamicType).URLForResource("biolit", withExtension: "html")!
        do { doc = try NSXMLDocument(contentsOfURL: URL, options: Extensions.MPDefaultXMLDocumentOutputOptions | NSXMLDocumentTidyHTML) }
        catch { XCTFail("Failed to initialize test document from URL \(URL).") }
        
        do {
            try docP.processedDocument(inputDocument: doc!, inPlace:true) { (elemProcessor, textNode, fragment, resolvedResult) in
                switch resolvedResult.result {
                case .BibliographyItems(let items):
                    XCTAssert(items.count == 1, "Unexpected number of items resolved: \(items)")
                    XCTAssert(items.first?.title == "From the analyst\'s couch: Selective anticancer drugs", "Unexpected title: '\(items.first?.title)'")
                default:
                    XCTFail("Failed to resolve a bibliography item for \(fragment)")
                }
                print("Text node: \(textNode), fragment:\(fragment), result:\(resolvedResult)")
            }
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
    
    func testXMLNodeSplitting() {
        let textNode = NSXMLNode(kind: .TextKind)
        textNode.stringValue = "foo bar baz"
        
        let splitAtFooNodes = textNode.split(atIndex: 3)
        let splitAtFoo = [splitAtFooNodes.0.stringValue!, splitAtFooNodes.1.stringValue!]
        
        XCTAssertEqual(splitAtFoo, ["foo", " bar baz"], "Unexpected split position: \(splitAtFoo)")
        
        let splitNodes = textNode.split(atIndices: [3, 4, 7, 8])
        let splitStringValues = splitNodes.map { $0.stringValue! }
        
        XCTAssertEqual(splitStringValues, ["foo", " ", "bar", " ", "baz"], "Unexpected splits: \(splitStringValues)")
    }
    
    func testXMLElementExtraction() {
        let str = "foobarbaz"
        let doc = try! NSXMLDocument(XMLString: "<p>\(str)</p>", options: MPDefaultXMLDocumentParsingOptions)
        let elem = doc.rootElement()!
        XCTAssertTrue(elem.name == "p")
        XCTAssertTrue(elem.children!.first!.stringValue == str)
        
        let range = elem.stringValue!.startIndex.advancedBy(3) ..< elem.stringValue!.startIndex.advancedBy(6)
        XCTAssertTrue(elem.stringValue?.substringWithRange(range) == "bar", "Got my arithmetic wrong.")
        XCTAssertTrue(elem.children!.count == 1)
        XCTAssertTrue(elem.children!.first!.kind == .TextKind)
        
        let splitNodes = elem.children!.first!.extract(elementWithName:"strong", range:3 ..< 6)
        
        XCTAssertTrue(splitNodes.before.stringValue == "foo")
        XCTAssertTrue(splitNodes.after.stringValue == "baz")
        XCTAssertTrue(splitNodes.extracted.name == "strong")
    }
    
    func testSimpleMultipleXMLElementExtraction() {
        let str = "foobarbaz"
        let doc = try! NSXMLDocument(XMLString: "<p>\(str)</p>", options: MPDefaultXMLDocumentParsingOptions)
        let elem = doc.rootElement()!
        XCTAssertTrue(elem.name == "p")
        XCTAssertTrue(elem.children!.first!.stringValue == str)
        
        let splitNodes = elem.children!.first!.extract(elementsWithName:"strong", ranges: [3 ..< 6])
        
        XCTAssertTrue(splitNodes[0].XMLString == "foo")
        XCTAssertTrue(splitNodes[1].XMLString == "<strong>bar</strong>", "Unexpected string value: \(splitNodes[1].stringValue)")
        XCTAssertTrue(splitNodes[2].XMLString == "baz")
    }
    
    func testComplexMultipleXMLElementExtractions() {
        let str = "foobarbazadoo"
        let doc = try! NSXMLDocument(XMLString: "<p>\(str)</p>", options: MPDefaultXMLDocumentParsingOptions)
        let elem = doc.rootElement()!
        XCTAssertTrue(elem.name == "p")
        XCTAssertTrue(elem.children!.first!.stringValue == str)
        
        let splitNodes = elem.children!.first!.extract(elementsWithName:"em", ranges: [2 ..< 4, 5 ..< 6, 7 ..< 9])
        
        let firstElemSubstr = str.substringWithRange(elem.stringValue!.startIndex.advancedBy(2) ..< elem.stringValue!.startIndex.advancedBy(4))
        XCTAssertTrue(firstElemSubstr == "ob")
        
        let secondElemSubstr = str.substringWithRange(elem.stringValue!.startIndex.advancedBy(5) ..< elem.stringValue!.startIndex.advancedBy(6))
        XCTAssertTrue(secondElemSubstr == "r")
        
        let thirdElemSubstr = str.substringWithRange(elem.stringValue!.startIndex.advancedBy(7) ..< elem.stringValue!.startIndex.advancedBy(9))
        XCTAssertTrue(thirdElemSubstr == "az")

        // foobarbazadoo
        // fo|ob|a|r|b|az|adoo
        XCTAssertTrue(splitNodes[0].XMLString == "fo")
        XCTAssertTrue(splitNodes[1].XMLString == "<em>ob</em>", "Unexpected string value: \(splitNodes[1].stringValue)")
        XCTAssertTrue(splitNodes[2].XMLString == "a")
        XCTAssertTrue(splitNodes[3].XMLString == "<em>r</em>")
        XCTAssertTrue(splitNodes[4].XMLString == "b")
        XCTAssertTrue(splitNodes[5].XMLString == "<em>az</em>")
    }
    
    
    func testProcessingMarkdown() {
        let resolvers:[Resolver] = [ MarkdownSyntaxComponentResolver(markdownComponentType:MarkdownAsteriskStrong.self),
                                     MarkdownSyntaxComponentResolver(markdownComponentType:MarkdownUnderscoreStrong.self),
                                     MarkdownSyntaxComponentResolver(markdownComponentType:MarkdownAsteriskEmphasis.self),
                                     MarkdownSyntaxComponentResolver(markdownComponentType:MarkdownUnderscoreEmphasis.self) ]
        
        var encounteredIDs:Set<String> = []
        
        let docP = ResolvingCompoundDocumentProcessor(resolvers: resolvers, replaceMatches: true)
        
        var doc:NSXMLDocument? = nil
        let URL:NSURL = NSBundle(forClass: self.dynamicType).URLForResource("biolit", withExtension: "html")!
        do { doc = try NSXMLDocument(contentsOfURL: URL, options: Extensions.MPDefaultXMLDocumentOutputOptions | NSXMLDocumentTidyHTML) }
        catch { XCTFail("Failed to initialize test document from URL \(URL).") }
        
        try! docP.processedDocument(inputDocument: doc!, inPlace: true) { (elementProcessor, textNode, fragment, resolvedResult) in
            
            switch resolvedResult.result {
            case .InlineElements(let elems):
                guard let resolvable = resolvedResult.resolvable as? MarkdownSyntaxComponent else {
                    XCTFail("Resolvable is unexpectedly not a MarkdownSyntaxComponent: \(resolvedResult.resolvable).")
                    break
                }
                
                XCTAssert(elems.count == 1, "Unexpected inline element count: \(elems)")
                
                encounteredIDs.insert(resolvable.identifier)
                
                switch resolvable.identifier {
                case "**delivers**":
                    XCTAssert(resolvable.innerHTML == "delivers", "Unexpected innerHTML: \(resolvable.innerHTML).")
                    XCTAssert(resolvable.tagName == "strong", "Unexpected tagName: \(resolvable.tagName).")
                    
                case "__that__":
                    XCTAssert(resolvable.innerHTML == "that", "Unexpected innerHTML: \(resolvable.innerHTML).")
                    XCTAssert(resolvable.tagName == "strong", "Unexpected tagName: \(resolvable.tagName).")
                    
                case "*resource*":
                    XCTAssert(resolvable.innerHTML == "resource", "Unexpected innerHTML: \(resolvable.innerHTML).")
                    XCTAssert(resolvable.tagName == "em", "Unexpected tagName: \(resolvable.tagName).")
                    
                case "_semantically_":
                    XCTAssert(resolvable.innerHTML == "semantically", "Unexpected innerHTML: \(resolvable.innerHTML).")
                    XCTAssert(resolvable.tagName == "em", "Unexpected tagName: \(resolvable.tagName).")
                    
                default:
                    break
                }
                
            case .BibliographyItems(_):
                break
                
            default:
                XCTFail("There should be no failed resolve calls.")
            }
        }
        
        for identifier in ["**delivers**", "__that__", "*resource*", "_semantically_"] {
            XCTAssert(encounteredIDs.contains(identifier), "Failed to resolve identifier \(identifier)")
        }
        
        let paddedBy2 = "foobar123foobar".stringAroundOccurrence(ofString: "123", maxPadding: 2)
        let paddedBy12 = "foobar123foobar".stringAroundOccurrence(ofString: "123", maxPadding: 12)
        XCTAssert(paddedBy2 == "ar123fo", "String matching")
        XCTAssert(paddedBy12 == "foobar123foobar", "String matching")
        
        
        let xmlStr = doc?.XMLStringWithOptions(MPDefaultXMLDocumentOutputOptions)
        
        let semanticallyPadded = xmlStr?.stringAroundOccurrence(ofString: "semantically", maxPadding: 10)

        XCTAssert(xmlStr!.containsString("<em>"), "XML string contains no instances of <em>")
    }
}
